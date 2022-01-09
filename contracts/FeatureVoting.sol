// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FeatureVoting is Ownable {
  using SafeMath for uint256;

  struct Feature {
    uint256 votes;
    string title;
    bool active;
    bool finished;
  }

  IERC20 energy;

  Feature[] public features;

  event FeatureAdded(uint256 indexed index, string title);
  event FeatureVoted(
    address indexed voter,
    uint256 indexed index,
    uint256 votes
  );

  constructor(address _energy) {
    energy = IERC20(_energy);
  }

  function setActive(uint256 _index, bool _active) public onlyOwner {
    features[_index].active = _active;
  }

  function addFeature(string memory _title) public onlyOwner {
    Feature memory feature;
    feature.active = true;
    feature.title = _title;
    features.push(feature);

    emit FeatureAdded(features.length - 1, _title);
  }

  function vote(uint256 _index, uint256 _votes) public {
    require(features[_index].active, "Feature is not active");
    require(energy.transferFrom(msg.sender, address(this), _votes));
    features[_index].votes = features[_index].votes.add(_votes);

    emit FeatureVoted(msg.sender, _index, _votes);
  }

  function featureFinished(uint256 _index) public onlyOwner {
    require(!features[_index].finished, "Feature request already finished");
    features[_index].finished = true;
    features[_index].active = false;
  }
}
