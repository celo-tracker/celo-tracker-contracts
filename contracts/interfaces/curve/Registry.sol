// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.2;

interface Registry {
    function pool_list(uint256 index) external view returns (address);

    function get_coins(address pool) external view returns (address[8] memory);

    function get_underlying_coins(address pool)
        external
        view
        returns (address[8] memory);

    function get_rates(address pool) external view returns (uint256[8] memory);

    function get_balances(address pool)
        external
        view
        returns (uint256[8] memory);

    function get_underlying_balances(address pool)
        external
        view
        returns (uint256[8] memory);

    function get_decimals(address pool)
        external
        view
        returns (uint256[8] memory);

    function get_underlying_decimals(address pool)
        external
        view
        returns (uint256[8] memory);

    function get_lp_token(address pool) external view returns (address);

    function is_meta(address pool) external view returns (bool);

    function get_pool_name(address pool) external view returns (string memory);

    function get_pool_asset_type(address pool) external view returns (uint256);

    function get_gauges(address pool)
        external
        view
        returns (address[10] memory, int128[10] memory);
}
