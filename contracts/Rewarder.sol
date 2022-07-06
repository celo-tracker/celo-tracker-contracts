// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

// Después pasa claimear un usuario tiene que pasar el índice
// en la lista del bloque en el que interactuó
// y el índice del objetivo que cumplió para que el contrato
// verifique ese bloque con el objetivo y vea si cumplió o no.
// Si cumplió debería marcarlo como "objetivo cumplido" también
// para que no pueda volver a hacerlo

import "./Energy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Rewarder is Ownable {
  Energy public energy;

  struct Objective {
    uint256 startingBlock;
    uint256 endingBlock;
    uint256 reward;
  }

  Objective[] public objectives;
  // origin address => user address => block list
  mapping(address => mapping(address => uint256[])) public userInteractionsByOrigin;
  mapping(address => mapping(uint256 => bool)) public objectivesCompletedByUser;

  // event triggered when user interacts with Rewarder
  // is there a better name?
  event UserInteraction(
    address indexed user,
    uint256 interactionIndex,
    uint256 objectiveIndex,
    address indexed originAddress
  );

  constructor(address _energy) {
    energy = Energy(_energy);
  }

  function onReward(address user) public {
    // save user interaction on userInteractionByContract
    // emit UserInteraction event
  }

  function claimReward(
    uint256 objectiveIndex,
    uint256 interactionIndex,
    address originAddress
  ) public {
    // verify that the interaction exists (userInteractionsByOrigin)
    // and the objective is not completed (objectivesCompletedByUser)
    // verify that the objective is valid (the blockNumber, retrived from userInteractionByOrigin
    // should be between the blocks defined for the objective -> objective[objectiveIndes])
  }

  //   function addObjective(uint256 _dailyReward) public onlyOwner {
  //     dailyReward = _dailyReward;
  //   }

  //   function mintDailyReward() public {
  //     require(block.timestamp > lastDailyReward[msg.sender] + 1 days, "Reward not available yet");
  //     lastDailyReward[msg.sender] = block.timestamp;
  //     energy.mint(msg.sender, dailyReward);
  //   }
}
