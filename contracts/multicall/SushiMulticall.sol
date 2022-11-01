// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../interfaces/sushiswap/IMiniChefV2.sol";
import "../interfaces/sushiswap/IRewarder.sol";
import "../interfaces/uniswap/IUniswapV2Pair.sol";

contract SushiMulticall {
    struct SushiPool {
        address poolAddress;
        uint256 amount0;
        address token0;
        uint256 amount1;
        address token1;
        uint256 miniChefPoolShare;
        uint256 miniChefAllocPoint;
        uint256 rewarderAllocPoint;
    }

    function getPools(IMiniChefV2 miniChef, address rewarder)
        external
        view
        returns (SushiPool[] memory pools)
    {
        uint256 poolCount = miniChef.poolLength();

        pools = new SushiPool[](poolCount);

        for (uint16 index = 0; index < poolCount; index++) {
            address lpToken = miniChef.lpToken(index);

            (
                address token0,
                address token1,
                uint256 reserve0,
                uint256 reserve1
            ) = getPoolInfo(lpToken);

            uint256 miniChefPoolShare = 0;
            uint256 own = IERC20(lpToken).balanceOf(address(miniChef));
            if (own != 0) {
                uint256 total = IERC20(lpToken).totalSupply();
                miniChefPoolShare = (own * 10**18) / total;
            }

            uint256 miniChefAllocPoint = miniChef.poolInfo(index).allocPoint;
            uint256 rewarderAllocPoint = rewarder == address(0)
                ? 0
                : IRewarder(rewarder).poolInfo(index).allocPoint;

            pools[index] = SushiPool(
                lpToken,
                reserve0,
                token0,
                reserve1,
                token1,
                miniChefPoolShare,
                miniChefAllocPoint,
                rewarderAllocPoint
            );
        }

        return pools;
    }

    function getPoolInfo(address lpToken)
        internal
        view
        returns (
            address token0,
            address token1,
            uint256 reserve0,
            uint256 reserve1
        )
    {
        IUniswapV2Pair pair = IUniswapV2Pair(lpToken);

        try pair.getReserves() returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32
        ) {
            return (pair.token0(), pair.token1(), _reserve0, _reserve1);
        } catch {
            return (address(0), address(0), 0, 0);
        }
    }
}
