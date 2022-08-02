// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ISwappaPairV1.sol";

contract PairBalancerV2 is ISwappaPairV1, Ownable {
    function swap(
        address input,
        address output,
        address to,
        bytes calldata data
    ) external override {
        address pairAddr = parseData(data);
        uint256 inputAmount = ERC20(input).balanceOf(address(this));
        IUniswapV3Pool pair = IUniswapV3Pool(pairAddr);
        bool zeroForOne = pair.token0() == input;
        // calling swap will trigger the uniswapV3SwapCallback
        pair.swap(
            to,
            zeroForOne,
            inputAmount.toInt256(),
            zeroForOne
                ? TickMath.MIN_SQRT_RATIO + 1
                : TickMath.MAX_SQRT_RATIO - 1,
            new bytes(0)
        );
    }

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external override {
        ERC20 token;
        uint256 amount;
        if (amount0Delta > 0) {
            amount = uint256(amount0Delta);
            token = ERC20(IUniswapV3Pool(msg.sender).token0());
        } else if (amount1Delta > 0) {
            amount = uint256(amount1Delta);
            token = ERC20(IUniswapV3Pool(msg.sender).token1());
        }
        require(
            token.transfer(msg.sender, amount),
            "PairUniswapV3: transfer failed!"
        );
    }

    function parseData(bytes memory data)
        private
        pure
        returns (address pairAddr)
    {
        require(data.length == 20, "PairUniswapV3: invalid data!");
        assembly {
            pairAddr := mload(add(data, 20))
        }
    }

    function getOutputAmount(
        address input,
        address output,
        uint256 amountIn,
        bytes calldata data
    ) external view override returns (uint256 amountOut) {
        address pairAddr = parseData(data);
        IUniswapV3Pool pair = IUniswapV3Pool(pairAddr);
        bool zeroForOne = pair.token0() == input;
        // amount0, amount1 are delta of the pair reserves
        (int256 amount0, int256 amount1) = QuoterDiwu.quote(
            pair,
            zeroForOne,
            amountIn.toInt256(),
            zeroForOne
                ? TickMath.MIN_SQRT_RATIO + 1
                : TickMath.MAX_SQRT_RATIO - 1
        );
        return uint256(-(zeroForOne ? amount1 : amount0));
    }

    function getInputAmount(
        address input,
        address output,
        uint256 amountOut,
        bytes calldata data
    ) external view returns (uint256 amountIn) {
        address pairAddr = parseData(data);
        IUniswapV3Pool pair = IUniswapV3Pool(pairAddr);
        bool zeroForOne = pair.token0() == input;
        // amount0, amount1 are delta of the pair reserves
        (int256 amount0, int256 amount1) = QuoterDiwu.quote(
            pair,
            zeroForOne,
            -amountOut.toInt256(),
            zeroForOne
                ? TickMath.MIN_SQRT_RATIO + 1
                : TickMath.MAX_SQRT_RATIO - 1
        );
        return uint256(zeroForOne ? amount0 : amount1);
    }

    function recoverERC20(ERC20 token) public onlyOwner {
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
}
