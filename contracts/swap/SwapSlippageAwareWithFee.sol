// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/ISwappaRouter.sol";

contract SwapSlippageAwareWithFee is Ownable {
    uint256 public constant MAX_FEE_NUMERATOR = 6_000; // max 60 bps.
    uint256 public constant FEE_DENOMINATOR = 1_000_000;

    uint256 public feeNumerator;
    address public beneficiary;
    ISwappaRouterV1 private swappaRouter;

    event Swap(
        address indexed userAddress,
        address indexed inputToken,
        address indexed outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 baseFee,
        uint256 fee
    );
    event BeneficiarySet(address newBeneficiary);
    event FeeNumeratorSet(uint256 feeNumerator);

    constructor(
        ISwappaRouterV1 _swappaRouter,
        address _beneficiary,
        uint256 initialFee
    ) {
        swappaRouter = _swappaRouter;
        setBeneficiary(_beneficiary);
        setFeeNumerator(initialFee);
    }

    function setBeneficiary(address _beneficiary) public onlyOwner {
        beneficiary = _beneficiary;
        emit BeneficiarySet(_beneficiary);
    }

    function setFeeNumerator(uint256 _feeNumerator) public onlyOwner {
        feeNumerator = _feeNumerator;
        emit FeeNumeratorSet(_feeNumerator);
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
        uint256 baseFee = (inputAmount * feeNumerator) / FEE_DENOMINATOR;
        if (baseFee > 0) {
            require(
                ERC20(path[0]).transferFrom(msg.sender, beneficiary, baseFee),
                "Fee payment failed"
            );
        }
        uint256 swapAmount = inputAmount - baseFee;
        require(
            ERC20(path[0]).transferFrom(msg.sender, address(this), swapAmount),
            "Swap initial transfer failed. Did you approve the funds?"
        );

        ERC20(path[0]).approve(address(swappaRouter), swapAmount);
        uint256 outputAmount = swappaRouter.swapExactInputForOutput(
            path,
            pairs,
            extras,
            swapAmount,
            minOutputAmount,
            address(this),
            deadline
        );

        // Sanity check, already checked by Swappa. Can be removed to save gas if needed.
        require(outputAmount >= minOutputAmount, "Insufficient output amount!");

        // We charge positive slippage as a fee if there is no base fee.
        uint256 amountToReturn = outputAmount > quotedOutputAmount &&
            baseFee == 0
            ? quotedOutputAmount
            : outputAmount;

        ERC20 outputToken = ERC20(path[path.length - 1]);
        require(
            outputToken.transfer(msg.sender, amountToReturn),
            "Output payment failed"
        );

        uint256 fee = outputToken.balanceOf(address(this));

        if (fee > 0) {
            require(
                outputToken.transfer(beneficiary, fee),
                "Fee payment failed"
            );
        }

        emit Swap(
            msg.sender,
            path[0],
            path[path.length - 1],
            swapAmount,
            amountToReturn,
            baseFee,
            fee
        );
    }
}
