// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IRewarder {
  function onReward(
    address user,
    address token0,
    address token1,
    uint256 token0Amount,
    uint256 token1Amount,
    uint256 percentMin
  ) external;
}
