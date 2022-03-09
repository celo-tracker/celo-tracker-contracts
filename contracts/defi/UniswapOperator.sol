// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/uniswap/IUniswapV2Router02.sol";
import "../interfaces/uniswap/IUniswapV2Pair.sol";
import "../interfaces/uniswap/libraries/UniswapV2Library.sol";

contract UniswapOperator {
  using SafeMath for uint256;

  address public immutable router;
  address public immutable factory;

  constructor(address _router, address _factory) {
    router = _router;
    factory = _factory;
  }

  function _swapUsingPool(
    address from,
    address to,
    uint256 inputAmount,
    uint256 minAmountOut
  ) internal returns (uint256 outAmount) {
    address pairAddress = UniswapV2Library.pairFor(factory, from, to);
    address[] memory path = new address[](2);
    path[0] = from;
    path[1] = to;

    require(
      IERC20(from).transfer(pairAddress, inputAmount),
      "UniswapOperator: Transfer failed"
    );
    IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);

    (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
    if (pair.token0() == from) {
      outAmount = getAmountOut(inputAmount, reserve0, reserve1);
      require(
        outAmount >= minAmountOut,
        "UniswapOperator: Not enough output amount"
      );
      pair.swap(0, outAmount, address(this), new bytes(0));
    } else {
      outAmount = getAmountOut(inputAmount, reserve1, reserve0);
      require(
        outAmount >= minAmountOut,
        "UniswapOperator: Not enough output amount"
      );
      pair.swap(outAmount, 0, address(this), new bytes(0));
    }
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

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) internal pure returns (uint256 amountOut) {
    uint256 amountInWithFee = amountIn.mul(997);
    uint256 numerator = amountInWithFee.mul(reserveOut);
    uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
    amountOut = numerator / denominator;
  }
}
