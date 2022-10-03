// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "../../interfaces/stableswap/ISwap.sol";
import "./Quoter.sol";

contract MobiusQuoter is Quoter {
    function getQuote(
        address from,
        address,
        uint256 amountIn,
        bytes memory data
    ) external view returns (uint256) {
        address poolAddress;
        assembly {
            poolAddress := mload(add(data, 20))
        }

        ISwap swapPool = ISwap(poolAddress);
        if (swapPool.getToken(0) == from) {
            return swapPool.calculateSwap(0, 1, amountIn);
        } else {
            return swapPool.calculateSwap(1, 0, amountIn);
        }
    }
}
