// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IVoter {
    function _ve() external view returns (address);

    function governor() external view returns (address);

    function emergencyCouncil() external view returns (address);

    function attachTokenToGauge(uint256 _tokenId, address account) external;

    function detachTokenFromGauge(uint256 _tokenId, address account) external;

    function emitDeposit(
        uint256 _tokenId,
        address account,
        uint256 amount
    ) external;

    function emitWithdraw(
        uint256 _tokenId,
        address account,
        uint256 amount
    ) external;

    function isWhitelisted(address token) external view returns (bool);

    function notifyRewardAmount(uint256 amount) external;

    function distribute(address _gauge) external;

    function gauges(address pool) external view returns (address);

    function isAlive(address gauge) external view returns (bool);

    function internal_bribes(address gauge) external view returns (address);

    function external_bribes(address gauge) external view returns (address);

    function weights(address gauge) external view returns (uint256);

    function totalWeight() external view returns (uint256);
}
