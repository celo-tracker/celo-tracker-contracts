// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./UniswapOperator.sol";
import "./UbeswapOperator.sol";
import "./SushiOperator.sol";

contract OperatorProxy is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  SushiOperator private sushiOperator;
  UbeswapOperator private ubeswapOperator;

  bool private isUbeswapInitialized = false;
  bool private isSushiswapInitialized = false;

  function setSushiOperator(
    address _router,
    address _factory,
    address _miniChef,
    address _rewarder
  ) external onlyOwner {
    sushiOperator = new SushiOperator(_router, _factory, _miniChef, _rewarder);
    isSushiswapInitialized = true;
  }

  function setUbeswapOperator(
    address _router,
    address _factory,
    address _rewarder
  ) external onlyOwner {
    ubeswapOperator = new UbeswapOperator(_router, _factory, _rewarder);
    isUbeswapInitialized = true;
  }

  /**
   *Sushiswap implementation
   */
  function swapAndZapInto(
    address from,
    address to,
    uint256 fromAmount,
    uint256 minAmountOut,
    uint256 percentMin,
    uint256 pid
  ) external {
    require(isSushiswapInitialized, "operator not initialized");
    IERC20(from).safeTransferFrom(msg.sender, address(this), fromAmount);
    IERC20(from).approve(address(sushiOperator), fromAmount);
    sushiOperator.swapAndZapInto(
      from,
      to,
      fromAmount,
      minAmountOut,
      percentMin,
      pid,
      msg.sender
    );
  }

  /**
   *Ubeswap implementation
   */
  function swapAndZapInto(
    address from,
    address to,
    uint256 fromAmount,
    uint256 minAmountOut,
    uint256 percentMin
  ) external {
    require(isUbeswapInitialized, "operator not initialized");
    IERC20(from).safeTransferFrom(msg.sender, address(this), fromAmount);
    IERC20(from).approve(address(ubeswapOperator), fromAmount);
    ubeswapOperator.swapAndZapInto(
      from,
      to,
      fromAmount,
      minAmountOut,
      percentMin,
      msg.sender
    );
  }

  /**
   *Sushiswap implementation
   */
  function zapInto(
    address token0,
    address token1,
    uint256 token0Amount,
    uint256 token1Amount,
    uint256 percentMin,
    uint256 pid
  ) external {
    require(isSushiswapInitialized, "operator not initialized");
    IERC20(token0).safeTransferFrom(msg.sender, address(this), token0Amount);
    IERC20(token1).safeTransferFrom(msg.sender, address(this), token1Amount);

    IERC20(token0).approve(address(sushiOperator), token0Amount);
    IERC20(token1).approve(address(sushiOperator), token1Amount);

    sushiOperator.zapInto(
      token0,
      token1,
      token0Amount,
      token1Amount,
      percentMin,
      pid,
      msg.sender
    );
  }

  /**
   *Ubeswap implementation
   */
  function zapInto(
    address token0,
    address token1,
    uint256 token0Amount,
    uint256 token1Amount,
    uint256 percentMin
  ) external {
    require(isUbeswapInitialized, "operator not initialized");
    IERC20(token0).safeTransferFrom(msg.sender, address(this), token0Amount);
    IERC20(token1).safeTransferFrom(msg.sender, address(this), token1Amount);

    IERC20(token0).approve(address(ubeswapOperator), token0Amount);
    IERC20(token1).approve(address(ubeswapOperator), token1Amount);

    ubeswapOperator.zapInto(
      token0,
      token1,
      token0Amount,
      token1Amount,
      percentMin,
      msg.sender
    );
  }
}
