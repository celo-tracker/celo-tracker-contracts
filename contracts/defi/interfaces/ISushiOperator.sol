// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface ISushiOperator {
  function swapAndZapIn(
    address from,
    address to,
    uint256 fromAmount,
    uint256 minAmountOut,
    uint256 percentMin,
    uint256 pid,
    address user
  ) external;

  function zapIn(
    address token0,
    address token1,
    uint256 token0Amount,
    uint256 token1Amount,
    uint256 percentMin,
    uint256 pid,
    address user
  ) external;
}
