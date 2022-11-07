// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "../../interfaces/velodrome/IPair.sol";
import "./Quoter.sol";

contract VelodromeQuoter is Quoter {
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

        IPair pair = IPair(pairAddress);

        try pair.getAmountOut(amountIn, from) returns (uint256 amountOut) {
            return amountOut;
        } catch {
            return 0;
        }
    }
}
