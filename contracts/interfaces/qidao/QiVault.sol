// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface QiVault {
    function getDebtCeiling() external view returns (uint256);

    function getClosingFee() external view returns (uint256);

    function getOpeningFee() external view returns (uint256);

    function getTokenPriceSource() external view returns (uint256);

    function getEthPriceSource() external view returns (uint256);

    function createVault() external returns (uint256);

    function destroyVault(uint256 vaultID) external;

    function transferVault(uint256 vaultID, address to) external;

    function depositCollateral(uint256 vaultID, uint256 amount) external;

    function withdrawCollateral(uint256 vaultID, uint256 amount) external;

    function borrowToken(uint256 vaultID, uint256 amount) external;

    function payBackToken(uint256 vaultID, uint256 amount) external;

    function buyRiskyVault(uint256 vaultID) external;

    function mai() external returns (address);
}
