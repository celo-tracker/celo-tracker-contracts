// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "../../interfaces/uniswapV3/IUniswapV3Pool.sol";
import "../../interfaces/uniswapV3/libraries/QuoterDiwu.sol";
import "../../interfaces/uniswapV3/libraries/SafeCast.sol";
import "./Quoter.sol";

contract UniswapV3Quoter is Quoter {
    using SafeCast for uint256;

    function getQuote(
        address from,
        address,
        uint256 amountIn,
        bytes memory data
    ) external view returns (uint256) {
        address pairAddress;
        assembly {
            pairAddress := mload(add(data, 20))
        }

        IUniswapV3Pool pair = IUniswapV3Pool(pairAddress);
        bool zeroForOne = pair.token0() == from;
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
}
