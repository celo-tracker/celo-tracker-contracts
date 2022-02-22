// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./interfaces/IRewarder.sol";
import "hardhat/console.sol";

contract RewarderTest is IRewarder {

    function onReward(
        address user,
        address token0,
        address token1,
        uint256 token0Amount,
        uint256 token1Amount,
        uint256 percentMin
    ) external override {}
}
