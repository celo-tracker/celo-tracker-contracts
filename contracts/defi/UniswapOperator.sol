// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/uniswap/IUniswapV2Router02.sol";
import "../interfaces/uniswap/libraries/UniswapV2Library.sol";

contract UniswapOperator {
  using SafeMath for uint256;

  address public immutable router;

  constructor(address _router) {
    router = _router;
  }

  function _swapUsingPool(
    address from,
    address to,
    uint256 inputAmount,
    uint256 minAmountOut
  ) internal returns (uint256 outAmount) {
    address[] memory path = new address[](2);
    path[0] = from;
    path[1] = to;

    IERC20(from).approve(router, inputAmount);
    uint256[] memory amounts = IUniswapV2Router02(router)
      .swapExactTokensForTokens(
        inputAmount,
        minAmountOut,
        path,
        address(this),
        block.timestamp
      );
    outAmount = amounts[1];
  }

  function _addLiquidity(
    address token0,
    address token1,
    uint256 token0Amount,
    uint256 token1Amount,
    uint256 percentMin
  ) internal {
    IERC20(token0).approve(router, token0Amount);
    IERC20(token1).approve(router, token1Amount);
    IUniswapV2Router02(router).addLiquidity(
      token0,
      token1,
      token0Amount,
      token1Amount,
      (token0Amount * percentMin) / 100,
      (token1Amount * percentMin) / 100,
      address(this),
      block.timestamp
    );
  }
}
