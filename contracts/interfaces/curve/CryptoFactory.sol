// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.2;

interface CryptoFactory {
    function pool_list(uint256 index) external view returns (address);

    function get_coins(address pool) external view returns (address[2] memory);

    function get_balances(address pool)
        external
        view
        returns (uint256[2] memory);

    function get_decimals(address pool)
        external
        view
        returns (uint256[2] memory);

    function get_gauge(address pool) external view returns (address);
}
