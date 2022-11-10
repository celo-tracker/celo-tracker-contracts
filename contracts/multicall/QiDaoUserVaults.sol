// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IVaultNFT {
    function balanceOf(address owner) external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256);
}

interface IVaultInfo {
    function _minimumCollateralPercentage() external view returns (uint256);

    function collateral() external view returns (address);

    function vaultCollateral(uint256 vaultId) external view returns (uint256);

    function vaultDebt(uint256 vaultId) external view returns (uint256);

    function checkCollateralPercentage(uint256 vaultId)
        external
        view
        returns (uint256);

    function openingFee() external view returns (uint256);

    function closingFee() external view returns (uint256);

    function getDebtCeiling() external view returns (uint256);

    function name() external view returns (string memory);
}

contract QiDaoUserVaults {
    struct Vault {
        address vaultInfo;
        address collateralToken;
        string name;
        uint256 openingFee;
        uint256 closingFee;
        uint256 minimumCollateralPercentage;
    }

    struct UserVault {
        address vaultInfo;
        address vaultNft;
        uint256 vaultId;
        uint256 collateral;
        uint256 debt;
        uint256 collateralPercentage;
    }

    function getVaults(address[] memory vaultsInfo)
        external
        view
        returns (Vault[] memory vaults)
    {
        vaults = new Vault[](vaultsInfo.length);
        for (uint256 i = 0; i < vaultsInfo.length; i++) {
            IVaultInfo vaultInfo = IVaultInfo(vaultsInfo[i]);
            address collateralToken = vaultInfo.collateral();
            string memory name = vaultInfo.name();
            uint256 openingFee = getOpeningFee(vaultInfo);
            uint256 closingFee = getClosingFee(vaultInfo);
            vaults[i] = Vault(
                vaultsInfo[i],
                collateralToken,
                name,
                openingFee,
                closingFee,
                vaultInfo._minimumCollateralPercentage()
            );
        }
    }

    function getUserVaults(
        address[] memory vaultNFTs,
        address[] memory vaultsInfo,
        address user
    ) external view returns (UserVault[] memory userVaults) {
        uint256 size = 0;
        for (uint256 i = 0; i < vaultNFTs.length; i++) {
            size = size + IVaultNFT(vaultNFTs[i]).balanceOf(user);
        }
        userVaults = new UserVault[](size);
        uint256 vaultIndex = 0;
        for (uint256 i = 0; i < vaultNFTs.length; i++) {
            uint256 userVaultCount = IVaultNFT(vaultNFTs[i]).balanceOf(user);
            if (userVaultCount == 0) {
                continue;
            }
            IVaultInfo vaultInfo = IVaultInfo(vaultsInfo[i]);
            for (uint256 j = 0; j < userVaultCount; j++) {
                uint256 vaultId = IVaultNFT(vaultNFTs[i]).tokenOfOwnerByIndex(
                    user,
                    j
                );
                uint256 collateral = vaultInfo.vaultCollateral(vaultId);
                uint256 debt = vaultInfo.vaultDebt(vaultId);
                uint256 collateralPercentage = vaultInfo
                    .checkCollateralPercentage(vaultId);
                userVaults[vaultIndex++] = UserVault(
                    vaultsInfo[i],
                    vaultNFTs[i],
                    vaultId,
                    collateral,
                    debt,
                    collateralPercentage
                );
            }
        }
    }

    function getOpeningFee(IVaultInfo vaultInfo)
        internal
        view
        returns (uint256)
    {
        try vaultInfo.openingFee() returns (uint256 fee) {
            return fee;
        } catch {
            return 0;
        }
    }

    function getClosingFee(IVaultInfo vaultInfo)
        internal
        view
        returns (uint256)
    {
        try vaultInfo.closingFee() returns (uint256 fee) {
            return fee;
        } catch {
            return 0;
        }
    }
}
