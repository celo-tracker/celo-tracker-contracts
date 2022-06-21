// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/ISwappaRouter.sol";

contract SwapSlippageAware is Ownable {
    address public beneficiary;
    ISwappaRouterV1 private swappaRouter;

    event Swap(
        address indexed userAddress,
        address indexed inputToken,
        address indexed outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 fee
    );
    event BeneficiarySet(address newBeneficiary);

    constructor(ISwappaRouterV1 _swappaRouter, address _beneficiary) {
        swappaRouter = _swappaRouter;
        setBeneficiary(_beneficiary);
    }

    function setBeneficiary(address _beneficiary) public onlyOwner {
        beneficiary = _beneficiary;
        emit BeneficiarySet(_beneficiary);
    }

    function emergencyWithdrawal(address token) external onlyOwner {
        ERC20(token).transfer(
            beneficiary,
            ERC20(token).balanceOf(address(this))
        );
    }

    function swap(
        address[] calldata path,
        address[] calldata pairs,
        bytes[] calldata extras,
        uint256 inputAmount,
        uint256 quotedOutputAmount,
        uint256 minOutputAmount,
        uint256 deadline
    ) external {
        ERC20 inputToken = ERC20(path[0]);

        require(
            inputToken.transferFrom(msg.sender, address(this), inputAmount),
            "Swap initial transfer failed. Did you approve the funds?"
        );

        inputToken.approve(address(swappaRouter), inputAmount);
        uint256 outputAmount = swappaRouter.swapExactInputForOutput(
            path,
            pairs,
            extras,
            inputAmount,
            minOutputAmount,
            address(this),
            deadline
        );

        // Sanity check, already checked by Swappa. Can be removed to save gas if needed.
        require(outputAmount >= minOutputAmount, "Insufficient output amount!");

        // We charge positive slippage as a fee.
        uint256 fee = outputAmount <= quotedOutputAmount
            ? 0
            : outputAmount - quotedOutputAmount;

        ERC20 outputToken = ERC20(path[path.length - 1]);
        if (fee > 0) {
            require(
                outputToken.transfer(beneficiary, fee),
                "Fee payment failed"
            );
        }
        require(
            outputToken.transfer(msg.sender, outputAmount - fee),
            "Output payment failed"
        );

        emit Swap(
            msg.sender,
            path[0],
            path[path.length - 1],
            inputAmount,
            outputAmount - fee,
            fee
        );
    }
}
