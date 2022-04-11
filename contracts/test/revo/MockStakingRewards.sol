// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IStakingRewards.sol";

contract MockStakingRewards is IStakingRewards {
  IERC20 public rewardsToken;

  IERC20 public stakingToken;

  constructor(address _rewardsToken, address _stakingToken) {
    rewardsToken = IERC20(_rewardsToken);
    stakingToken = IERC20(_stakingToken);
  }

  // Views
  function lastTimeRewardApplicable() external view override returns (uint256) {
    // farm bot shouldn't need this
    require(false);
    return 0;
  }

  function rewardPerToken() external view override returns (uint256) {
    // farm bot shouldn't need this
    require(false);
    return 0;
  }

  uint256 public amountEarned;

  function setAmountEarned(uint256 _amountEarned) public {
    amountEarned = _amountEarned;
  }

  function earned(address account) external view override returns (uint256) {
    return amountEarned;
  }

  function getRewardForDuration() external view override returns (uint256) {
    // farm bot shouldn't need this
    require(false);
    return 0;
  }

  function totalSupply() external view override returns (uint256) {
    // farm bot shouldn't need this
    require(false);
    return 0;
  }

  uint256 public accountBalance;

  function setAccountBalance(uint256 _accountBalance) external {
    accountBalance = _accountBalance;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return accountBalance;
  }

  // Mutative
  mapping(address => uint256) public staked;

  function stake(uint256 amount) external override {
    staked[msg.sender] += amount;
    stakingToken.transferFrom(msg.sender, address(this), amount);
  }

  function withdraw(uint256 amount) external override {
    require(staked[msg.sender] >= amount);
    staked[msg.sender] -= amount;
    stakingToken.transfer(msg.sender, amount);
    this.getReward();
  }

  function getReward() external override {
    rewardsToken.transfer(msg.sender, amountEarned);
  }

  function exit() external override {
    // farm bot shouldn't need this
    require(false);
  }
}
