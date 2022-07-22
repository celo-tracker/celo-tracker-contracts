// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.2;

interface GaugeFactory {
    function minted(address userAddress, address gauge)
        external
        view
        returns (uint256);

    function get_gauge_count() external view returns (uint256);

    function get_gauge(uint256 index) external view returns (address);
}
