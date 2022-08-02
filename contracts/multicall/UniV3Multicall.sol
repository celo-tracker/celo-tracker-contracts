// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/uniswapV3/INonfungiblePositionManager.sol";
import "../interfaces/uniswapV3/IUniswapV3Factory.sol";
import "../interfaces/uniswapV3/IUniswapV3Pool.sol";
import "../interfaces/uniswapV3/libraries/TickMath.sol";
import "../interfaces/uniswapV3/libraries/LiquidityAmounts.sol";

contract UniV3Multicall is Ownable {
    struct UniV3Pool {
        address poolAddress;
        address token0;
        address token1;
        uint256 token0Balance;
        uint256 token1Balance;
        uint256 price;
    }

    function getPools(address[] memory poolAddresses)
        external
        view
        returns (UniV3Pool[] memory pools)
    {
        pools = new UniV3Pool[](poolAddresses.length);

        for (uint16 index = 0; index < poolAddresses.length; index++) {
            IUniswapV3Pool pool = IUniswapV3Pool(poolAddresses[index]);
            uint256 token0Balance = ERC20(pool.token0()).balanceOf(
                address(pool)
            );
            uint256 token1Balance = ERC20(pool.token1()).balanceOf(
                address(pool)
            );

            uint128 liquidity = pool.liquidity();
            uint256 price = 0;
            if (liquidity > 0) {
                (uint160 sqrtPriceX96, , , , , , ) = pool.slot0();
                price = sqrtPriceX96;
            }

            pools[index] = UniV3Pool(
                address(pool),
                pool.token0(),
                pool.token1(),
                token0Balance,
                token1Balance,
                price
            );
        }
    }
}
