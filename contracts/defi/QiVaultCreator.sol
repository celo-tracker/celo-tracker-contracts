// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../interfaces/qidao/QiVault.sol";

contract QiVaultCreator is Ownable {
    event VaultCreated(
        uint256 vaultId,
        address vaultAddress,
        address collateralToken,
        uint256 collateralAmount,
        uint256 debtAmount
    );

    function initiateVault(
        address vaultAddress,
        address collateralToken,
        uint256 collateralAmount,
        uint256 debtAmount
    ) external returns (uint256 vaultId) {
        require(
            IERC20(collateralToken).transferFrom(
                msg.sender,
                address(this),
                collateralAmount
            ),
            "QVC: Collateral transfer failed"
        );
        QiVault vault = QiVault(vaultAddress);
        vaultId = vault.createVault();

        IERC20(collateralToken).approve(vaultAddress, collateralAmount);
        vault.depositCollateral(vaultId, collateralAmount);
        vault.borrowToken(vaultId, debtAmount);

        require(
            IERC20(vault.mai()).transfer(msg.sender, debtAmount),
            "QVC: MAI transfer failed"
        );

        IERC721(vaultAddress).safeTransferFrom(
            address(this),
            msg.sender,
            vaultId
        );

        emit VaultCreated(
            vaultId,
            vaultAddress,
            collateralToken,
            collateralAmount,
            debtAmount
        );
    }

    /// Shouldn't be necessary, this contract doesn't hold funds. Here just in case of emergency.
    function exec(
        address target,
        uint256 value,
        bytes calldata data
    ) external onlyOwner {
        (bool success, bytes memory reason) = target.call{value: value}(data);
        require(success, string(reason));
    }
}
