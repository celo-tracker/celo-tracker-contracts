// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./Quoter.sol";

contract OneToOneQuoter is Quoter {
    function getQuote(
        address,
        address,
        uint256 amountIn,
        bytes memory
    ) external pure returns (uint256) {
        return amountIn;
    }
}
