// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/ISushiOperator.sol";
import "./interfaces/IUbeswapOperator.sol";

contract OperatorProxy is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  ISushiOperator private sushiOperator;
  IUbeswapOperator private ubeswapOperator;

  constructor(address _sushiOperator, address _ubeswapOperator) {
    sushiOperator = ISushiOperator(_sushiOperator);
    ubeswapOperator = IUbeswapOperator(_ubeswapOperator);
  }

  function swapAndZapInWithSushiwap(
    address from,
    address to,
    uint256 fromAmount,
    uint256 minAmountOut,
    uint256 percentMin,
    uint256 pid
  ) external {
    IERC20(from).safeTransferFrom(msg.sender, address(this), fromAmount);
    IERC20(from).safeApprove(address(sushiOperator), fromAmount);

    sushiOperator.swapAndZapIn(
      from,
      to,
      fromAmount,
      minAmountOut,
      percentMin,
      pid,
      msg.sender
    );
  }

  function swapAndZapInWithUbeswap(
    address from,
    address to,
    uint256 fromAmount,
    uint256 minAmountOut,
    uint256 percentMin
  ) external {
    IERC20(from).safeTransferFrom(msg.sender, address(this), fromAmount);
    IERC20(from).safeApprove(address(ubeswapOperator), fromAmount);

    ubeswapOperator.swapAndZapIn(
      from,
      to,
      fromAmount,
      minAmountOut,
      percentMin,
      msg.sender
    );
  }

  function zapInWithSushiswap(
    address token0,
    address token1,
    uint256 token0Amount,
    uint256 token1Amount,
    uint256 percentMin,
    uint256 pid
  ) external {
    IERC20(token0).safeTransferFrom(msg.sender, address(this), token0Amount);
    IERC20(token1).safeTransferFrom(msg.sender, address(this), token1Amount);

    IERC20(token0).safeApprove(address(sushiOperator), token0Amount);
    IERC20(token1).safeApprove(address(sushiOperator), token1Amount);

    sushiOperator.zapIn(
      token0,
      token1,
      token0Amount,
      token1Amount,
      percentMin,
      pid,
      msg.sender
    );
  }

  function zapInWithUbeswap(
    address token0,
    address token1,
    uint256 token0Amount,
    uint256 token1Amount,
    uint256 percentMin
  ) external {
    IERC20(token0).safeTransferFrom(msg.sender, address(this), token0Amount);
    IERC20(token1).safeTransferFrom(msg.sender, address(this), token1Amount);

    IERC20(token0).safeApprove(address(ubeswapOperator), token0Amount);
    IERC20(token1).safeApprove(address(ubeswapOperator), token1Amount);

    ubeswapOperator.zapIn(
      token0,
      token1,
      token0Amount,
      token1Amount,
      percentMin,
      msg.sender
    );
  }
}
