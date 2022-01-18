// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/sushiswap/IMiniChefV2.sol";
import "../interfaces/uniswap/IUniswapV2Router02.sol";
import "../interfaces/uniswap/libraries/UniswapV2Library.sol";
import "./UniswapOperator.sol";

contract SushiOperator is UniswapOperator, AccessControl {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  address public immutable factory;
  IMiniChefV2 public immutable miniChef;

  constructor(
    address _router,
    address _factory,
    address _miniChef
  ) UniswapOperator(_router) {
    factory = _factory;
    miniChef = IMiniChefV2(_miniChef);
  }

  receive() external payable {}

  function zapIntoSushi(
    address from,
    address to,
    uint256 fromAmount,
    uint256 minAmountOut,
    uint256 percentMin,
    uint256 pid
  ) public {
    IERC20(from).safeTransferFrom(msg.sender, address(this), fromAmount);
    uint256 halfFromAmount = fromAmount / 2;
    uint256 toAmount = _swapUsingPool(from, to, halfFromAmount, minAmountOut);

    _addLiquidityAndDepositInFarm(
      from,
      to,
      halfFromAmount,
      toAmount,
      percentMin,
      pid
    );

    // Return leftovers
    IERC20(from).transfer(msg.sender, IERC20(from).balanceOf(address(this)));
    IERC20(to).transfer(msg.sender, IERC20(to).balanceOf(address(this)));
  }

  function _addLiquidityAndDepositInFarm(
    address token0,
    address token1,
    uint256 token0Amount,
    uint256 token1Amount,
    uint256 percentMin,
    uint256 pid
  ) internal {
    _addLiquidity(token0, token1, token0Amount, token1Amount, percentMin);

    address lpToken = UniswapV2Library.pairFor(factory, token0, token1);
    uint256 lpBalance = IERC20(lpToken).balanceOf(address(this));
    IERC20(lpToken).approve(address(miniChef), lpBalance);
    miniChef.deposit(pid, lpBalance, msg.sender);
  }
}
