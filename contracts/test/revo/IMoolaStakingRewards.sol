// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface IMoolaStakingRewards {
  // Views

  function lastTimeRewardApplicable() external view returns (uint256);

  function rewardPerToken() external view returns (uint256);

  function earned(address account) external view returns (uint256);

  function earnedExternal(address account)
    external
    returns (uint256[] calldata);

  function getRewardForDuration() external view returns (uint256);

  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  // Mutative

  function stake(uint256 amount) external;

  function withdraw(uint256 amount) external;

  function getReward() external;

  function exit() external;
}
