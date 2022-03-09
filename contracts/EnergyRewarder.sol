// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./Energy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EnergyRewarder is Ownable {
  uint256 public dailyReward;
  Energy public energy;

  mapping(address => uint256) public lastDailyReward;

  constructor(uint256 _dailyReward, address _energy) {
    dailyReward = _dailyReward;
    energy = Energy(_energy);
  }

  function setDailyReward(uint256 _dailyReward) public onlyOwner {
    dailyReward = _dailyReward;
  }

  function mintDailyReward() public {
    require(
      block.timestamp > lastDailyReward[msg.sender] + 1 days,
      "Reward not available yet"
    );
    lastDailyReward[msg.sender] = block.timestamp;
    energy.mint(msg.sender, dailyReward);
  }
}
