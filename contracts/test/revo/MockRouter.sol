// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IUniswapV2Router01.sol";
import "./MockLPToken.sol";

contract MockRouter is IUniswapV2Router01 {
  MockLPToken lpToken;

  function factory() external pure override returns (address) {
    require(false, "Shouldn't use factory for mock router");
    return address(0);
  }

  uint256 mockLiquidity;

  function setMockLiquidity(uint256 _liquidity) public {
    mockLiquidity = _liquidity;
  }

  function setLPToken(address _lpToken) public {
    lpToken = MockLPToken(_lpToken);
  }

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  )
    external
    override
    returns (
      uint256 amountA,
      uint256 amountB,
      uint256 liquidity
    )
  {
    amountA = amountADesired;
    amountB = amountBDesired;
    IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
    IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);
    liquidity = mockLiquidity;
    lpToken.mint(msg.sender, mockLiquidity);
  }

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external override returns (uint256 amountA, uint256 amountB) {
    amountA = amountAMin;
    amountB = amountBMin;
    lpToken.burn(msg.sender, liquidity);
    IERC20(tokenA).transfer(msg.sender, amountA);
    IERC20(tokenB).transfer(msg.sender, amountB);
  }

  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external override returns (uint256 amountA, uint256 amountB) {
    require(false, "Not implemented");
    amountA = amountAMin;
    amountB = amountBMin;
  }

  uint256[] mockAmounts;

  function setMockAmounts(uint256[] memory amounts) public {
    mockAmounts = new uint256[](amounts.length);
    for (uint256 idx = 0; idx < amounts.length; idx++) {
      mockAmounts[idx] = amounts[idx];
    }
  }

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external override returns (uint256[] memory amounts) {
    require(amountIn > 0, "Cannot swap zero of token");
    MockERC20(path[0]).burn(msg.sender, amountIn);
    amounts = mockAmounts;
    MockERC20(path[path.length - 1]).mint(
      msg.sender,
      amounts[amounts.length - 1]
    );
  }

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external override returns (uint256[] memory amounts) {
    return mockAmounts;
  }

  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) external pure override returns (uint256 amountB) {
    amountB = (reserveB / reserveA) * amountA;
  }

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure override returns (uint256 amountOut) {
    return (reserveOut / reserveIn) * amountIn;
  }

  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure override returns (uint256 amountIn) {
    return (reserveIn / reserveOut) * amountOut;
  }

  function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    override
    returns (uint256[] memory amounts)
  {
    return mockAmounts;
  }

  function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    override
    returns (uint256[] memory amounts)
  {
    return mockAmounts;
  }
}
