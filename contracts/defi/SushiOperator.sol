// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/sushiswap/IMiniChefV2.sol";
import "../interfaces/uniswap/IUniswapV2Router02.sol";
import "../interfaces/uniswap/libraries/UniswapV2Library.sol";
import "./UniswapOperator.sol";
import "./interfaces/IRewarder.sol";

contract SushiOperator is UniswapOperator, Ownable {
  using SafeMath for uint256;

  IMiniChefV2 public immutable miniChef;
  IRewarder private rewarder;

  constructor(
    address _router,
    address _factory,
    address _miniChef,
    address _rewarder
  ) UniswapOperator(_router, _factory) {
    miniChef = IMiniChefV2(_miniChef);
    rewarder = IRewarder(_rewarder);
  }

  receive() external payable {}

  function setRewarder(address _rewarder) public onlyOwner {
    rewarder = IRewarder(_rewarder);
  }

  function swapAndZapIn(
    address from,
    address to,
    uint256 fromAmount,
    uint256 minAmountOut,
    uint256 percentMin,
    uint256 pid,
    address user
  ) external {
    require(
      IERC20(from).transferFrom(msg.sender, address(this), fromAmount),
      "SushiOperator: Failed to transferFrom from amount"
    );
    uint256 halfFromAmount = fromAmount / 2;
    uint256 toAmount = _swapUsingPool(from, to, halfFromAmount, minAmountOut);

    _zapIn(from, to, halfFromAmount, toAmount, percentMin, pid, user);
  }

  function zapIn(
    address token0,
    address token1,
    uint256 token0Amount,
    uint256 token1Amount,
    uint256 percentMin,
    uint256 pid,
    address user
  ) external {
    require(
      IERC20(token0).transferFrom(msg.sender, address(this), token0Amount),
      "SushiOperator: Failed to transferFrom token0"
    );
    require(
      IERC20(token1).transferFrom(msg.sender, address(this), token1Amount),
      "SushiOperator: Failed to transferFrom token1"
    );

    _zapIn(token0, token1, token0Amount, token1Amount, percentMin, pid, user);
  }

  function _zapIn(
    address token0,
    address token1,
    uint256 token0Amount,
    uint256 token1Amount,
    uint256 percentMin,
    uint256 pid,
    address user
  ) internal {
    _addLiquidityAndDepositInFarm(
      token0,
      token1,
      token0Amount,
      token1Amount,
      percentMin,
      pid,
      user
    );

    rewarder.onReward(
      user,
      token0,
      token1,
      token0Amount,
      token1Amount,
      percentMin
    );

    // Return leftovers
    IERC20(token0).transfer(user, IERC20(token0).balanceOf(address(this)));
    IERC20(token1).transfer(user, IERC20(token1).balanceOf(address(this)));
  }

  function _addLiquidityAndDepositInFarm(
    address token0,
    address token1,
    uint256 token0Amount,
    uint256 token1Amount,
    uint256 percentMin,
    uint256 pid,
    address user
  ) internal {
    _addLiquidity(token0, token1, token0Amount, token1Amount, percentMin);

    address lpToken = UniswapV2Library.pairFor(factory, token0, token1);
    uint256 lpBalance = IERC20(lpToken).balanceOf(address(this));
    IERC20(lpToken).approve(address(miniChef), lpBalance);
    miniChef.deposit(pid, lpBalance, user);
  }
}
