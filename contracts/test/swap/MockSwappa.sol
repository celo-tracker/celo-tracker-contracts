// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../../interfaces/ISwappaRouter.sol";

contract MockSwappa is ISwappaRouterV1 {
    address token0;
    address token1;

    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
    }

    function getOutputAmount(
        address[] calldata path,
        address[] calldata pairs,
        bytes[] calldata extras,
        uint256 inputAmount
    ) public view returns (uint256 outputAmount) {
        address inputToken = path[0];
        address outputToken = path[path.length - 1];
        if (inputToken == token0 && outputToken == token1) {
            return
                (inputAmount * ERC20(token1).balanceOf(address(this))) /
                ERC20(token0).balanceOf(address(this));
        } else if (inputToken == token1 && outputToken == token0) {
            return
                (inputAmount * ERC20(token0).balanceOf(address(this))) /
                ERC20(token1).balanceOf(address(this));
        }
        revert("tokens not supported");
    }

    function swapExactInputForOutput(
        address[] calldata path,
        address[] calldata pairs,
        bytes[] calldata extras,
        uint256 inputAmount,
        uint256 minOutputAmount,
        address to,
        uint256 deadline
    ) public returns (uint256 outputAmount) {
        outputAmount = getOutputAmount(path, pairs, extras, inputAmount);
        require(
            ERC20(path[0]).transferFrom(msg.sender, address(this), inputAmount)
        );
        require(ERC20(path[path.length - 1]).transfer(to, outputAmount));
    }

    function swapExactInputForOutputWithPrecheck(
        address[] calldata path,
        address[] calldata pairs,
        bytes[] calldata extras,
        uint256 inputAmount,
        uint256 minOutputAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 outputAmount) {
        return
            swapExactInputForOutput(
                path,
                pairs,
                extras,
                inputAmount,
                minOutputAmount,
                to,
                deadline
            );
    }
}
