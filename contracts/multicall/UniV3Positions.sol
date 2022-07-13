// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../interfaces/uniswapV3/INonfungiblePositionManager.sol";
import "../interfaces/uniswapV3/IUniswapV3Factory.sol";
import "../interfaces/uniswapV3/IUniswapV3Pool.sol";
import "../interfaces/uniswapV3/libraries/TickMath.sol";
import "../interfaces/uniswapV3/libraries/LiquidityAmounts.sol";

contract UniV3Positions {
    INonfungiblePositionManager public positionsManager;
    IUniswapV3Factory public factory;

    constructor(address positionsManagerAddress, address factoryAddress) {
        positionsManager = INonfungiblePositionManager(positionsManagerAddress);
        factory = IUniswapV3Factory(factoryAddress);
    }

    struct UniV3Position {
        address poolAddress;
        uint96 nonce;
        address operator;
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint128 liquidity;
        uint256 amount0;
        uint256 amount1;
        uint256 feeGrowthInside0LastX128;
        uint256 feeGrowthInside1LastX128;
        uint128 tokensOwed0;
        uint128 tokensOwed1;
    }

    function getPositions(uint256[] calldata tokenIds)
        external
        view
        returns (UniV3Position[] memory)
    {
        UniV3Position[] memory positions = new UniV3Position[](tokenIds.length);

        for (uint256 index = 0; index < tokenIds.length; index++) {
            (
                uint96 nonce,
                address operator,
                address token0,
                address token1,
                uint24 fee,
                int24 tickLower,
                int24 tickUpper,
                uint128 liquidity,
                uint256 feeGrowthInside0LastX128,
                uint256 feeGrowthInside1LastX128,
                uint128 tokensOwed0,
                uint128 tokensOwed1
            ) = positionsManager.positions(tokenIds[index]);
            uint160 lowerSqrt = TickMath.getSqrtRatioAtTick(tickLower);
            uint160 upperSqrt = TickMath.getSqrtRatioAtTick(tickUpper);

            IUniswapV3Pool pool = IUniswapV3Pool(
                factory.getPool(token0, token1, fee)
            );

            (uint160 currentPriceSqrt, , , , , , ) = pool.slot0();

            (uint256 amount0, uint256 amount1) = LiquidityAmounts
                .getAmountsForLiquidity(
                    currentPriceSqrt,
                    lowerSqrt,
                    upperSqrt,
                    liquidity
                );

            positions[index] = UniV3Position(
                address(pool),
                nonce,
                operator,
                token0,
                token1,
                fee,
                tickLower,
                tickUpper,
                liquidity,
                amount0,
                amount1,
                feeGrowthInside0LastX128,
                feeGrowthInside1LastX128,
                tokensOwed0,
                tokensOwed1
            );
        }

        return positions;
    }
}
