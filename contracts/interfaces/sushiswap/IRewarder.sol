// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IRewarder {
  struct PoolInfo {
    uint128 accSushiPerShare;
    uint64 lastRewardTime;
    uint64 allocPoint;
  }

  function onSushiReward(
    uint256 pid,
    address user,
    address recipient,
    uint256 sushiAmount,
    uint256 newLpAmount
  ) external;

  function pendingTokens(
    uint256 pid,
    address user,
    uint256 sushiAmount
  ) external view returns (IERC20[] memory, uint256[] memory);

  function rewardPerSecond() external view returns (uint256);

  function poolInfo(uint256 id) external view returns (PoolInfo memory);
}
