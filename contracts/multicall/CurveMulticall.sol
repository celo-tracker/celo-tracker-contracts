// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/curve/Registry.sol";
import "../interfaces/curve/PoolInfo.sol";
import "../interfaces/curve/MetapoolFactory.sol";
import "../interfaces/curve/CryptoRegistry.sol";
import "../interfaces/curve/CryptoFactory.sol";
import "../interfaces/curve/CryptoFactoryPool.sol";
import "../interfaces/curve/CurvePool.sol";

contract CurveMulticall is Ownable {
    struct BasePool {
        address poolAddress;
    }

    struct CurvePoolInfo {
        address poolAddress;
        address[8] tokens;
        address[8] underlyingTokens;
        uint256[8] balances;
        uint256[8] underlyingBalances;
        uint256 fee;
        uint256[8] rates;
        address lpToken;
        bool isMeta;
        string name;
        uint256 assetType;
        address[10] gauges;
        int128[10] gaugeTypes;
    }

    struct CurveMetapool {
        address poolAddress;
        string name;
        address basePool;
        address[4] tokens;
        address[8] underlyingTokens;
        uint256[4] balances;
        uint256[8] underlyingBalances;
        uint256 fee;
        bool isMeta;
        uint256 assetType;
        address gauge;
    }

    struct CurveCryptoPool {
        address poolAddress;
        address[8] tokens;
        uint256[8] balances;
        uint256 fee;
        address lpToken;
        string name;
        address[10] gauges;
        int128[10] gaugeTypes;
        address zap;
    }

    struct CurveCryptoFactoryPool {
        address poolAddress;
        address lpToken;
        address[2] tokens;
        uint256[2] balances;
        uint256 fee;
        address gauge;
    }

    function getPools(
        Registry registry,
        uint16 from,
        uint16 pageSize
    ) external view returns (CurvePoolInfo[] memory pools) {
        pools = new CurvePoolInfo[](pageSize);

        for (uint16 index = from; index < from + pageSize; index++) {
            address pool = registry.pool_list(index);

            address[8] memory tokens = registry.get_coins(pool);
            address[8] memory underlyingTokens = registry.get_underlying_coins(
                pool
            );
            uint256[8] memory balances = registry.get_balances(pool);
            uint256[8] memory underlyingBalances = registry
                .get_underlying_balances(pool);
            uint256[8] memory rates = registry.get_rates(pool);
            address lpToken = registry.get_lp_token(pool);
            bool isMeta = registry.is_meta(pool);
            string memory name = registry.get_pool_name(pool);
            uint256 assetType = registry.get_pool_asset_type(pool);
            (address[10] memory gauges, int128[10] memory gaugeTypes) = registry
                .get_gauges(pool);

            pools[index - from] = CurvePoolInfo(
                pool,
                tokens,
                underlyingTokens,
                balances,
                underlyingBalances,
                getPoolFee(pool),
                rates,
                lpToken,
                isMeta,
                name,
                assetType,
                gauges,
                gaugeTypes
            );
        }
    }

    function getMetaPools(
        MetapoolFactory factory,
        uint16 from,
        uint16 pageSize
    ) external view returns (CurveMetapool[] memory pools) {
        pools = new CurveMetapool[](pageSize);

        for (uint16 index = from; index < from + pageSize; index++) {
            address pool = factory.pool_list(index);

            address basePool = factory.get_base_pool(pool);
            address[4] memory tokens = factory.get_coins(pool);
            bool isMeta = factory.is_meta(pool);
            address[8] memory underlyingTokens;
            if (isMeta) {
                underlyingTokens = factory.get_underlying_coins(pool);
            }
            uint256[4] memory balances = factory.get_balances(pool);
            uint256[8] memory underlyingBalances;
            if (isMeta) {
                underlyingBalances = factory.get_underlying_balances(pool);
            }
            uint256 assetType = factory.get_pool_asset_type(pool);
            address gauge = factory.get_gauge(pool);

            pools[index - from] = CurveMetapool(
                pool,
                ERC20(pool).name(),
                basePool,
                tokens,
                underlyingTokens,
                balances,
                underlyingBalances,
                getPoolFee(pool),
                isMeta,
                assetType,
                gauge
            );
        }
    }

    function getCryptoPools(
        CryptoRegistry registry,
        uint16 from,
        uint16 pageSize
    ) external view returns (CurveCryptoPool[] memory pools) {
        pools = new CurveCryptoPool[](pageSize);

        for (uint16 index = from; index < from + pageSize; index++) {
            address pool = registry.pool_list(index);

            address[8] memory tokens = registry.get_coins(pool);
            string memory name = registry.get_pool_name(pool);
            uint256[8] memory balances = registry.get_balances(pool);
            address lpToken = registry.get_lp_token(pool);
            (address[10] memory gauges, int128[10] memory gaugeTypes) = registry
                .get_gauges(pool);
            address zap = registry.get_zap(pool);

            pools[index - from] = CurveCryptoPool(
                pool,
                tokens,
                balances,
                getPoolFee(pool),
                lpToken,
                name,
                gauges,
                gaugeTypes,
                zap
            );
        }
    }

    function getFactoryCryptoPools(
        CryptoFactory factory,
        uint16 from,
        uint16 pageSize
    ) external view returns (CurveCryptoFactoryPool[] memory pools) {
        pools = new CurveCryptoFactoryPool[](pageSize);

        for (uint16 index = from; index < from + pageSize; index++) {
            address pool = factory.pool_list(index);

            address[2] memory tokens = factory.get_coins(pool);
            uint256[2] memory balances = factory.get_balances(pool);
            address lpToken = CryptoFactoryPool(pool).token();
            address gauge = factory.get_gauge(pool);

            pools[index - from] = CurveCryptoFactoryPool(
                pool,
                lpToken,
                tokens,
                balances,
                getPoolFee(pool),
                gauge
            );
        }
    }

    function getPoolFee(address pool) public view returns (uint256) {
        try CurvePool(pool).fee() returns (uint256 fee) {
            return fee;
        } catch {
            return 0;
        }
    }

    // Shouldn't hold funds, just in case.
    function recoverFunds(address to, address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(IERC20(token).transfer(to, balance), "Token recovery failed");
    }
}
