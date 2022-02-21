// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IUbeswapOperator {
  function swapAndZapIn(
    address from,
    address to,
    uint256 fromAmount,
    uint256 minAmountOut,
    uint256 percentMin,
    address user
  ) external;

  function zapIn(
    address token0,
    address token1,
    uint256 token0Amount,
    uint256 token1Amount,
    uint256 percentMin,
    address user
  ) external;
}
