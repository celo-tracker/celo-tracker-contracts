// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../../defi/interfaces/IRewarderNew.sol";
import "hardhat/console.sol";

contract MockSwap {
  IRewarderNew private rewarder;

  event RewardForSwap(address indexed user, uint256 index);

  constructor(address _rewarder) {
    rewarder = IRewarderNew(_rewarder);
  }

  function swap() public {
    uint256 rewardIndex = rewarder.onReward(msg.sender);
    emit RewardForSwap(msg.sender, rewardIndex);
  }
}
