// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface ISwappaRouterV1 {
    function getOutputAmount(
        address[] calldata path,
        address[] calldata pairs,
        bytes[] calldata extras,
        uint256 inputAmount
    ) external view returns (uint256 outputAmount);

    function swapExactInputForOutput(
        address[] calldata path,
        address[] calldata pairs,
        bytes[] calldata extras,
        uint256 inputAmount,
        uint256 minOutputAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 outputAmount);

    function swapExactInputForOutputWithPrecheck(
        address[] calldata path,
        address[] calldata pairs,
        bytes[] calldata extras,
        uint256 inputAmount,
        uint256 minOutputAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 outputAmount);
}
