// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.2;

interface MetapoolFactory {
    function pool_count() external view returns (uint256);

    function pool_list(uint256 index) external view returns (address);

    function base_pool_count() external view returns (uint256);

    function base_pool_list(uint256 index) external view returns (address);

    function get_base_pool(address pool) external view returns (address);

    function get_coins(address pool) external view returns (address[4] memory);

    function get_underlying_coins(address pool)
        external
        view
        returns (address[8] memory);

    function get_metapool_rates(address pool)
        external
        view
        returns (uint256[2] memory);

    function get_balances(address pool)
        external
        view
        returns (uint256[4] memory);

    function get_underlying_balances(address pool)
        external
        view
        returns (uint256[8] memory);

    function get_decimals(address pool)
        external
        view
        returns (uint256[4] memory);

    function get_underlying_decimals(address pool)
        external
        view
        returns (uint256[8] memory);

    function get_implementation_address(address pool)
        external
        view
        returns (address);

    function is_meta(address pool) external view returns (bool);

    function get_pool_asset_type(address pool) external view returns (uint256);

    function get_gauge(address pool) external view returns (address);

    function metapool_implementations(address basePool)
        external
        view
        returns (address[10] memory);
}
