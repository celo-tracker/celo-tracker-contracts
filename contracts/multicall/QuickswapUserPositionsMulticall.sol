// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../interfaces/quickswap/IStakingRewards.sol";
import "../interfaces/quickswap/IStakingDualRewards.sol";
import "../interfaces/uniswap/IUniswapV2Pair.sol";

contract QuickswapUserPositionsMulticall is Ownable {

  struct QuickswapSingleRewardPosition {
    address poolAddress;
    uint256 share;
    address rewardsToken;
    uint256 rewardAmount;
  }

  struct QuickswapDualRewardPosition {
    address poolAddress;
    uint256 share;
    address rewardsTokenA;
    uint256 rewardAmountA;
    address rewardsTokenB;
    uint256 rewardAmountB;
  }

  function getSingleRewardPositions(
    address[] memory stakingRewardAddresses,
    address owner
  ) external view returns (QuickswapSingleRewardPosition[] memory positions) {
    uint256 poolCount = stakingRewardAddresses.length;

    positions = new QuickswapSingleRewardPosition[](poolCount);

    for (uint16 index = 0; index < poolCount; index++) {
      IStakingRewards stakingRewards = IStakingRewards(
        stakingRewardAddresses[index]
      );

      uint256 own = stakingRewards.balanceOf(owner);
      if (own == 0) {
        continue;
      }
      uint256 totalSupply = stakingRewards.totalSupply();
      uint256 share = (own * 10**18) / totalSupply;

      address rewardsToken = stakingRewards.rewardsToken();
      uint256 earnedRewards = stakingRewards.earned(owner);

      positions[index] = QuickswapSingleRewardPosition(
        stakingRewards.stakingToken(),
        share,
        rewardsToken,
        earnedRewards
      );
    }

    return positions;
  }

  function getDualRewardPositions(
    address[] memory stakingRewardAddresses,
    address owner
  ) external view returns (QuickswapDualRewardPosition[] memory positions) {
    uint256 poolCount = stakingRewardAddresses.length;

    positions = new QuickswapDualRewardPosition[](poolCount);

    for (uint16 index = 0; index < poolCount; index++) {
      IStakingDualRewards stakingRewards = IStakingDualRewards(
        stakingRewardAddresses[index]
      );

      uint256 own = stakingRewards.balanceOf(owner);
      if (own == 0) {
        continue;
      }
      uint256 totalSupply = stakingRewards.totalSupply();
      uint256 share = (own * 10**18) / totalSupply;

      address rewardsTokenA = stakingRewards.rewardsTokenA();
      uint256 earnedA = stakingRewards.earnedA(owner);
      address rewardsTokenB = stakingRewards.rewardsTokenB();
      uint256 earnedB = stakingRewards.earnedB(owner);

      positions[index] = QuickswapDualRewardPosition(
        stakingRewards.stakingToken(),
        share,
        rewardsTokenA,
        earnedA,
        rewardsTokenB,
        earnedB
      );
    }

    return positions;
  }
}
