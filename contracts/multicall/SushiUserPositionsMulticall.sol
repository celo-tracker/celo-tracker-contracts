// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../interfaces/sushiswap/IMiniChefV2.sol";
import "../interfaces/sushiswap/IRewarder.sol";
import "../interfaces/uniswap/IUniswapV2Pair.sol";

contract SushiUserPositionsMulticall {
  struct SushiPosition {
    address poolAddress;
    uint256 share;
    IERC20[] rewardTokens;
    uint256[] rewardAmounts;
    uint256 pendingSushi;
  }

  function getPositions(
    IMiniChefV2 miniChef,
    IRewarder rewarder,
    address owner
  ) external view returns (SushiPosition[] memory) {
    uint256 poolCount = miniChef.poolLength();

    SushiPosition[] memory positions = new SushiPosition[](poolCount);
    for (uint256 index = 0; index < poolCount; index++) {
      (uint256 amount, ) = miniChef.userInfo(index, owner);
      if (amount == 0) {
        continue;
      }
      address lpToken = miniChef.lpToken(index);
      IUniswapV2Pair pair = IUniswapV2Pair(lpToken);
      uint256 totalSupply = pair.totalSupply();
      uint256 share = (amount * 10**18) / totalSupply;

      uint256 pendingSushi = miniChef.pendingSushi(index, owner);
      (IERC20[] memory rewardTokens, uint256[] memory rewardAmounts) = rewarder
        .pendingTokens(index, owner, pendingSushi);

      positions[index] = (SushiPosition(
        lpToken,
        share,
        rewardTokens,
        rewardAmounts,
        pendingSushi
      ));
    }

    return positions;
  }
}
