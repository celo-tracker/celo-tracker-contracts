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
        bool borrowingEnabled;
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
        // Lending pool info
        uint256 totalDeposits;
        uint256 availableLiquidity;
        uint256 totalStableDebt;
        uint256 totalVariableDebt;
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
                ,
                ,
                ,
                ,
                ,
                bool usageAsCollateralEnabled,
                bool borrowingEnabled,
                ,
                ,

            ) = dataProvider.getReserveConfigurationData(reserveList[i]);
            (
                uint256 currentATokenBalance,
                uint256 currentStableDebt,
                uint256 currentVariableDebt,
                ,
                ,
                uint256 userStableBorrowRate,
                uint256 liquidityRate,
                ,

            ) = dataProvider.getUserReserveData(reserveList[i], user);
            (
                uint256 availableLiquidity,
                uint256 totalStableDebt,
                uint256 totalVariableDebt,
                ,
                ,
                ,
                ,
                ,
                ,

            ) = dataProvider.getReserveData(reserveList[i]);

            uint256 totalDeposits = ERC20(reserveData.aTokenAddress).totalSupply();

            reserves[i] = AaveReserve(
                reserveList[i],
                reserveData.aTokenAddress,
                currentATokenBalance,
                liquidityRate,
                usageAsCollateralEnabled,
                borrowingEnabled,
                userConfig.isUsingAsCollateral(i),
                userConfig.isBorrowing(i),
                currentStableDebt,
                reserveData.stableDebtTokenAddress,
                reserveData.currentStableBorrowRate,
                userStableBorrowRate,
                currentVariableDebt,
                reserveData.variableDebtTokenAddress,
                reserveData.currentVariableBorrowRate,
                totalDeposits,
                availableLiquidity,
                totalStableDebt,
                totalVariableDebt
            );
        }
    }
}
