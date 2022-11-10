// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../interfaces/velodrome/IPairFactory.sol";
import "../interfaces/velodrome/IPair.sol";
import "../interfaces/velodrome/IVoter.sol";

contract VeloPoolsMulticall {
    struct VeloPool {
        address poolAddress;
        address token0;
        address token1;
        uint256 token0Balance;
        uint256 token1Balance;
        address gauge;
        bool isStable;
    }

    function getAllPools(
        IPairFactory factory,
        IVoter voter,
        uint256 start,
        uint256 end
    ) external view returns (VeloPool[] memory pools) {
        pools = new VeloPool[](end - start + 1);

        for (uint256 i = start; i <= end; i++) {
            IPair pair = IPair(factory.allPairs(i));
            uint256 token0Balance = balanceOf(pair.token0(), address(pair));
            uint256 token1Balance = balanceOf(pair.token1(), address(pair));

            pools[i - start] = VeloPool(
                address(pair),
                pair.token0(),
                pair.token1(),
                token0Balance,
                token1Balance,
                voter.gauges(address(pair)),
                pair.stable()
            );
        }
    }

    function getPools(IVoter voter, address[] memory poolAddresses)
        external
        view
        returns (VeloPool[] memory pools)
    {
        pools = new VeloPool[](poolAddresses.length);

        for (uint16 index = 0; index < poolAddresses.length; index++) {
            IPair pair = IPair(poolAddresses[index]);
            uint256 token0Balance = balanceOf(pair.token0(), address(pair));
            uint256 token1Balance = balanceOf(pair.token1(), address(pair));

            pools[index] = VeloPool(
                address(pair),
                pair.token0(),
                pair.token1(),
                token0Balance,
                token1Balance,
                voter.gauges(address(pair)),
                pair.stable()
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
        bool isStable;
    }

    function getPoolAddresses(
        IPairFactory factory,
        PoolAddresses[] memory pools
    ) external view returns (address[] memory poolAddresses) {
        poolAddresses = new address[](pools.length);

        for (uint16 index = 0; index < pools.length; index++) {
            address token0 = pools[index].token0;
            address token1 = pools[index].token1;
            (address tokenA, address tokenB) = token0 < token1
                ? (token0, token1)
                : (token1, token0);
            poolAddresses[index] = factory.getPair(
                tokenA,
                tokenB,
                pools[index].isStable
            );
        }
    }
}
