// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./Energy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract Rewarder is Ownable {
  Energy public energy;

  struct Objective {
    uint256 startingBlock;
    uint256 endingBlock;
    uint256 reward;
    address origin;
  }

  Objective[] private objectives;

  // origin address => user address => block list
  mapping(address => mapping(address => uint256[])) public userInteractionsByOrigin;
  // user address => objectiveIndex => claimed
  mapping(address => mapping(uint256 => bool)) public objectivesCompletedByUser;

  // un nombre mejor?
  event UserInteraction(address indexed user, uint256 interactionIndex, address indexed originAddress);
  event ObjectiveAdded(uint256 indexed index, uint256 reward, address indexed creator);
  event RewardClaimed(address indexed user, uint256 reward, uint256 indexed objectiveIndex);

  modifier hasObjective(address origin) {
    bool objective = false;
    for (uint256 i = 0; i < objectives.length; i++) {
      if (objectives[i].origin == origin) {
        objective = true;
        break;
      }
    }
    require(objective, "No reward assigned to msg.sender");
    _;
  }

  constructor(address _energy) {
    energy = Energy(_energy);
  }

  function getObjectives() external view returns (Objective[] memory) {
    return objectives;
  }

  function onReward(address user) public hasObjective(msg.sender) returns (uint256 interactionIndex) {
    userInteractionsByOrigin[msg.sender][user].push(block.number);
    interactionIndex = userInteractionsByOrigin[msg.sender][user].length - 1;
    emit UserInteraction(user, interactionIndex, msg.sender);
    return interactionIndex;
  }

  function getObjectiveByOrigin(address origin) external view returns (int256 index) {
    for (uint256 i = 0; i < objectives.length; i++) {
      if (objectives[i].origin == origin) {
        return int256(i);
      }
    }
    return -1;
  }

  function claimReward(
    uint256 objectiveIndex,
    uint256 interactionIndex,
    address originAddress,
    address user
  ) public {
    uint256 interactionBlock = userInteractionsByOrigin[originAddress][msg.sender][interactionIndex];
    require(interactionBlock > 0, "There is no reward to claim");
    require(!objectivesCompletedByUser[user][objectiveIndex], "The reward has been claimed");

    Objective memory objective = objectives[objectiveIndex];
    require(interactionBlock >= objective.startingBlock, "The reward can't be claimed yet");
    require(interactionBlock < objective.endingBlock, "The reward has expired");
    require(originAddress == objective.origin, "Objective doesn't match origin address");

    objectivesCompletedByUser[user][objectiveIndex] = true;
    energy.mint(user, objective.reward);

    emit RewardClaimed(user, objective.reward, objectiveIndex);
  }

  function addObjective(
    uint256 reward,
    address origin,
    uint256 startingBlock,
    uint256 endingBlock
  ) public onlyOwner {
    Objective memory objective;
    objective.reward = reward;
    objective.origin = origin;
    objective.startingBlock = startingBlock;
    objective.endingBlock = endingBlock;
    objectives.push(objective);

    uint256 index = objectives.length - 1;

    emit ObjectiveAdded(index, reward, msg.sender);
  }
}
