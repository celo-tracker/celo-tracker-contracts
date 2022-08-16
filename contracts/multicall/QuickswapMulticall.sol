// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/quickswap/IStakingRewards.sol";
import "../interfaces/quickswap/IStakingDualRewards.sol";
import "../interfaces/uniswap/IUniswapV2Pair.sol";

contract QuickswapMulticall is Ownable {
  
  struct QuickswapSingleRewardPool {
    address poolAddress;
    address farmAddress;
    uint256 amount0;
    address token0;
    uint256 amount1;
    address token1;
    uint256 rewardRate;
    address rewardsToken;
  }

  struct QuickswapDualRewardPool {
    address poolAddress;
    address farmAddress;
    uint256 amount0;
    address token0;
    uint256 amount1;
    address token1;
    uint256 rewardRateA;
    address rewardsTokenA;
    uint256 rewardRateB;
    address rewardsTokenB;
  }

  function getSingleRewardPools(address[] memory stakingRewardAddresses)
    external
    view
    returns (QuickswapSingleRewardPool[] memory pools)
  {
    uint256 poolCount = stakingRewardAddresses.length;

    pools = new QuickswapSingleRewardPool[](poolCount);

    for (uint16 index = 0; index < poolCount; index++) {
      IStakingRewards stakingRewards = IStakingRewards(
        stakingRewardAddresses[index]
      );

      address pairAddress = stakingRewards.stakingToken();
      IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
      (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
      address token0 = pair.token0();
      address token1 = pair.token1();

      address rewardsToken = stakingRewards.rewardsToken();
      uint256 rewardRate = stakingRewards.rewardRate();

      pools[index] = QuickswapSingleRewardPool(
        pairAddress,
        stakingRewardAddresses[index],
        reserve0,
        token0,
        reserve1,
        token1,
        rewardRate,
        rewardsToken
      );
    }

    return pools;
  }

  function getDualRewardPools(address[] memory stakingRewardAddresses)
    external
    view
    returns (QuickswapDualRewardPool[] memory pools)
  {
    uint256 poolCount = stakingRewardAddresses.length;

    pools = new QuickswapDualRewardPool[](poolCount);

    for (uint16 index = 0; index < poolCount; index++) {
      IStakingDualRewards stakingRewards = IStakingDualRewards(
        stakingRewardAddresses[index]
      );

      address pairAddress = stakingRewards.stakingToken();
      IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
      (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
      address token0 = pair.token0();
      address token1 = pair.token1();

      address rewardsTokenA = stakingRewards.rewardsTokenA();
      address rewardsTokenB = stakingRewards.rewardsTokenA();
      uint256 rewardRateA = stakingRewards.rewardRateA();
      uint256 rewardRateB = stakingRewards.rewardRateB();

      pools[index] = QuickswapDualRewardPool(
        pairAddress,
        stakingRewardAddresses[index],
        reserve0,
        token0,
        reserve1,
        token1,
        rewardRateA,
        rewardsTokenA,
        rewardRateB,
        rewardsTokenB
      );
    }

    return pools;
  }
}
