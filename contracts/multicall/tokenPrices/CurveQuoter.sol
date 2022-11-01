// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./Quoter.sol";

interface BasePool {
    function coins(uint256 index) external view returns (address);

    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);
}

interface BasePool2 {
    function coins(uint256 index) external view returns (address);

    function get_dy(
        uint256 i,
        uint256 j,
        uint256 dx
    ) external view returns (uint256);
}

contract CurveQuoter is Quoter {
    function getQuote(
        address from,
        address to,
        uint256 amountIn,
        bytes memory data
    ) external view returns (uint256) {
        address poolAddress;
        assembly {
            poolAddress := mload(add(data, 20))
        }

        BasePool basePool = BasePool(poolAddress);

        (uint128 i, uint128 j) = findIndexes(basePool, from, to);
        try basePool.get_dy(int128(i), int128(j), amountIn) returns (
            uint256 quote
        ) {
            return quote;
        } catch {
            return BasePool2(poolAddress).get_dy(i, j, amountIn);
        }
    }

    function findIndexes(
        BasePool basePool,
        address t0,
        address t1
    ) internal view returns (uint128 i, uint128 j) {
        i = j = 100;

        for (uint16 x = 0; x <= 3; x++) {
            address token = basePool.coins(x);
            if (t0 == token) {
                i = x;
            } else if (t1 == token) {
                j = x;
            }
            if (i != 100 && j != 100) {
                break;
            }
        }
    }
}
