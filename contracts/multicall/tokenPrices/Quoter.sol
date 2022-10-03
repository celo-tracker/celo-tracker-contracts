// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface Quoter {
    function getQuote(
        address from,
        address to,
        uint256 amountIn,
        bytes calldata data
    ) external view returns (uint256);
}
