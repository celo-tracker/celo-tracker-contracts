// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Quoter.sol";

contract TokenPrices {
    struct TokenQuery {
        address from;
        address to;
        uint256 amountIn;
        address quoter;
        bytes data;
    }

    function getQuotes(TokenQuery[] memory queries)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory quotes = new uint256[](queries.length);

        for (uint256 index = 0; index < queries.length; index++) {
            TokenQuery memory query = queries[index];
            try
                Quoter(query.quoter).getQuote(
                    query.from,
                    query.to,
                    query.amountIn,
                    query.data
                )
            returns (uint256 quote) {
                quotes[index] = quote;
            } catch {
                quotes[index] = 0;
            }
        }

        return quotes;
    }
}
