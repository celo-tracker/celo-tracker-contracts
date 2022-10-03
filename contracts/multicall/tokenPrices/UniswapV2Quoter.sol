// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "../../interfaces/uniswap/IUniswapV2Pair.sol";
import "./Quoter.sol";

contract UniswapV2Quoter is Quoter {
    function getQuote(
        address from,
        address,
        uint256 amountIn,
        bytes memory data
    ) external view returns (uint256) {
        uint256 fee = uint256(10000) - uint8(data[20]);
        address pairAddress;
        assembly {
            pairAddress := mload(add(data, 20))
        }

        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);

        try pair.getReserves() returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32
        ) {
            (uint112 reserveIn, uint112 reserveOut) = pair.token0() == from
                ? (reserve0, reserve1)
                : (reserve1, reserve0);
            return getAmountOut(amountIn, reserveIn, reserveOut, fee);
        } catch {
            return 0;
        }
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut,
        uint256 feeK
    ) internal pure returns (uint256 amountOut) {
        uint256 amountInWithFee = amountIn * feeK;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 10000 + amountInWithFee;
        amountOut = numerator / denominator;
    }
}
