//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "./IMoolaStakingRewards.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./RevoUniswapStakingTokenStrategy.sol";
import "./IMoolaStakingRewards.sol";

/**
 * RevoUbeswapFarmBot is a farmbot:
 *   * that runs on top of an IMoolaStakingRewards farm
 *   * whose stakingToken is an IUniswapV2Pair ("LP")
 *   * that acquires LP constintuent tokens through swaps on an IUniswapV2Router02
 *   * that mints LP from constituent tokens through an IUniswapV2Router02
 *
 * This farmbot is suitable for use on top of a handful of Ubeswap yield farming positions.
 **/
contract RevoUbeswapFarmBot is RevoUniswapStakingTokenStrategy {
  using SafeERC20 for IERC20;

  IMoolaStakingRewards public stakingRewards;

  constructor(
    address _owner,
    address _reserveAddress,
    address _stakingRewards,
    address _stakingToken,
    address _revoFees,
    address[] memory _rewardsTokens,
    address _swapRouter,
    address _liquidityRouter,
    string memory _symbol
  )
    RevoUniswapStakingTokenStrategy(
      _owner,
      _reserveAddress,
      _stakingToken,
      _revoFees,
      _rewardsTokens,
      _swapRouter,
      _liquidityRouter,
      _symbol
    )
  {
    stakingRewards = IMoolaStakingRewards(_stakingRewards);
  }

  function _deposit(uint256 _lpAmount) internal override whenNotPaused {
    require(_lpAmount > 0, "Cannot invest in farm because lpAmount is 0");
    stakingToken.safeIncreaseAllowance(address(stakingRewards), _lpAmount);
    stakingRewards.stake(_lpAmount);
  }

  function _withdraw(uint256 _lpAmount) internal override {
    stakingRewards.withdraw(_lpAmount);
  }

  function _claimRewards() internal override whenNotPaused {
    stakingRewards.getReward();
  }
}
