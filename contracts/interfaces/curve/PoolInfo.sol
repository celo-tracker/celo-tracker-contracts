// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.2;

interface PoolInfo {
    struct Params {
        uint256 A;
        uint256 futureA;
        uint256 fee;
        uint256 adminFee;
        uint256 futureFee;
        uint256 futureAdminFee;
        address futureOwner;
        uint256 initialA;
        uint256 initialAtime;
        uint256 futureAtime;
    }

    function get_pool_coins(address pool)
        external
        view
        returns (
            address[8] memory,
            address[8] memory,
            uint256[8] memory,
            uint256[8] memory
        );

    function get_pool_info(address pool)
        external
        view
        returns (
            uint256[8] memory,
            uint256[8] memory,
            uint256[8] memory,
            uint256[8] memory,
            uint256[8] memory,
            address,
            Params memory,
            bool,
            string memory
        );
}
