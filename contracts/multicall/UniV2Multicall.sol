// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/uniswap/IUniswapV2Factory.sol";
import "../interfaces/uniswap/IUniswapV2Pair.sol";

contract UniV2Multicall is Ownable {
    struct UniV2Pool {
        address poolAddress;
        address token0;
        address token1;
        uint256 token0Balance;
        uint256 token1Balance;
    }

    function getAllPools(
        IUniswapV2Factory factory,
        uint256 start,
        uint256 end
    ) external view returns (UniV2Pool[] memory pools) {
        pools = new UniV2Pool[](end - start + 1);

        for (uint256 i = start; i <= end; i++) {
            IUniswapV2Pair pair = IUniswapV2Pair(factory.allPairs(i));
            uint256 token0Balance = balanceOf(pair.token0(), address(pair));
            uint256 token1Balance = balanceOf(pair.token1(), address(pair));

            pools[i - start] = UniV2Pool(
                address(pair),
                pair.token0(),
                pair.token1(),
                token0Balance,
                token1Balance
            );
        }
    }

    function getPools(address[] memory poolAddresses)
        external
        view
        returns (UniV2Pool[] memory pools)
    {
        pools = new UniV2Pool[](poolAddresses.length);

        for (uint16 index = 0; index < poolAddresses.length; index++) {
            IUniswapV2Pair pair = IUniswapV2Pair(poolAddresses[index]);
            uint256 token0Balance = balanceOf(pair.token0(), address(pair));
            uint256 token1Balance = balanceOf(pair.token1(), address(pair));

            pools[index] = UniV2Pool(
                address(pair),
                pair.token0(),
                pair.token1(),
                token0Balance,
                token1Balance
            );
        }
    }

    function balanceOf(address token, address target)
        internal
        view
        returns (uint256)
    {
        if (token.code.length == 0) {
            return 0;
        }
        try ERC20(token).balanceOf(target) returns (uint256 balance) {
            return balance;
        } catch {
            return 0;
        }
    }

    struct PoolAddresses {
        address token0;
        address token1;
    }

    function getPoolAddresses(
        IUniswapV2Factory factory,
        PoolAddresses[] memory pools
    ) external view returns (address[] memory poolAddresses) {
        poolAddresses = new address[](pools.length);

        for (uint16 index = 0; index < pools.length; index++) {
            address token0 = pools[index].token0;
            address token1 = pools[index].token1;
            (address tokenA, address tokenB) = token0 < token1
                ? (token0, token1)
                : (token1, token0);
            poolAddresses[index] = factory.getPair(tokenA, tokenB);
        }
    }
}
