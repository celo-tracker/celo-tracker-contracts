// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FeatureVoting is Ownable {
  using SafeMath for uint256;

  struct Feature {
    address creator;
    uint256 votes;
    string title;
    bool active;
    bool finished;
  }

  IERC20 energy;

  Feature[] public features;

  event FeatureAdded(
    uint256 indexed index,
    string title,
    address indexed creator
  );
  event FeatureVoted(
    address indexed voter,
    uint256 indexed index,
    uint256 votes
  );
  // Emitted when a feature request changes it's active status.
  event FeatureStatusUpdated(uint256 indexed index, bool active, bool finished);

  constructor(address _energy) {
    energy = IERC20(_energy);
  }

  function totalFeaturesCount() external view returns (uint256 count) {
    return features.length;
  }

  function setActive(uint256 _index, bool _active) external onlyOwner {
    features[_index].active = _active;
    emit FeatureStatusUpdated(_index, _active, features[_index].finished);
  }

  function addFeature(string memory _title, uint256 _votes) external returns (uint256 index) {
    Feature memory feature;
    feature.creator = msg.sender;
    feature.active = true;
    feature.title = _title;
    features.push(feature);

    index = features.length - 1;

    emit FeatureAdded(index, _title, msg.sender);

    vote(index, _votes);
  }

  function vote(uint256 _index, uint256 _votes) public {
    require(features[_index].active, "Feature is not active");
    require(energy.transferFrom(msg.sender, address(this), _votes));
    features[_index].votes = features[_index].votes.add(_votes);

    emit FeatureVoted(msg.sender, _index, _votes);
  }

  function featureFinished(uint256 _index) external onlyOwner {
    require(!features[_index].finished, "Feature request already finished");
    features[_index].finished = true;
    features[_index].active = false;
    emit FeatureStatusUpdated(_index, false, true);
  }
}
