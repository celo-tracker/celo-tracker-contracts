// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IRewarderNew {
  function onReward(address user) external returns (uint256 index);
  
  function claimReward(
    uint256 objectiveIndex,
    uint256 interactionIndex,
    address originAddress,
    address user
  ) external; 

  function getObjectiveByOrigin(address origin) external view returns (int256 index); 
}
