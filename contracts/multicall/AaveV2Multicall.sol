// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/aaveV2/ILendingPool.sol";
import "../interfaces/aaveV2/IDataProvider.sol";
import "../interfaces/aaveV2/UserConfiguration.sol";

contract AaveV2Multicall is Ownable {
    using UserConfiguration for DataTypes.UserConfigurationMap;

    struct AaveReserve {
        address token;
        address aToken;
        uint256 totalDeposited;
        uint256 liquidityRate;
        bool usageAsCollateralEnabled;
        bool isUsingAsCollateral;
        bool isBorrowing;
        // Stable Debt
        uint256 stableDebt;
        address stableDebtToken;
        uint128 stableBorrowRate;
        uint256 userStableBorrowRate;
        // Variable Debt
        uint256 variableDebt;
        address variableDebtToken;
        uint128 variableBorrowRate;
    }

    function getReservesWithUserData(
        ILendingPool lendingPool,
        IDataProvider dataProvider,
        address user
    ) external view returns (AaveReserve[] memory reserves) {
        address[] memory reserveList = lendingPool.getReservesList();
        reserves = new AaveReserve[](reserveList.length);

        DataTypes.UserConfigurationMap memory userConfig = lendingPool
            .getUserConfiguration(user);

        for (uint256 i = 0; i < reserveList.length; i++) {
            DataTypes.ReserveData memory reserveData = lendingPool
                .getReserveData(reserveList[i]);
            (
                uint256 currentATokenBalance,
                uint256 currentStableDebt,
                uint256 currentVariableDebt,
                ,
                ,
                uint256 userStableBorrowRate,
                uint256 liquidityRate,
                ,
                bool usageAsCollateralEnabled
            ) = dataProvider.getUserReserveData(reserveList[i], user);

            reserves[i] = AaveReserve(
                reserveList[i],
                reserveData.aTokenAddress,
                currentATokenBalance,
                liquidityRate,
                usageAsCollateralEnabled,
                userConfig.isUsingAsCollateral(i),
                userConfig.isBorrowing(i),
                currentStableDebt,
                reserveData.stableDebtTokenAddress,
                reserveData.currentStableBorrowRate,
                userStableBorrowRate,
                currentVariableDebt,
                reserveData.variableDebtTokenAddress,
                reserveData.currentVariableBorrowRate
            );
        }
    }
}