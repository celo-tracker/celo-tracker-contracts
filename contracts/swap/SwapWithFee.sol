// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/ISwappaRouter.sol";

contract SwapWithFee is Ownable {
    uint256 public constant MAX_FEE_NUMERATOR = 6_000; // max 60 bps.
    uint256 public constant FEE_DENOMINATOR = 1_000_000;

    uint256 feeNumerator;
    address beneficiary;
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

    function swap(
        address[] calldata path,
        address[] calldata pairs,
        bytes[] calldata extras,
        uint256 inputAmount,
        uint256 minOutputAmount,
        uint256 deadline
    ) external {
        uint256 fee = (inputAmount * feeNumerator) / FEE_DENOMINATOR;
        address inputToken = path[0];
        require(
            ERC20(inputToken).transferFrom(msg.sender, beneficiary, fee),
            "Fee payment failed"
        );
        uint256 swapAmount = inputAmount - fee;
        require(
            ERC20(inputToken).transferFrom(
                msg.sender,
                address(this),
                swapAmount
            ),
            "Swap initial transfer failed. Did you approve the funds?"
        );

        ERC20(inputToken).approve(address(swappaRouter), swapAmount);
        uint256 outputAmount = swappaRouter.swapExactInputForOutput(
            path,
            pairs,
            extras,
            swapAmount,
            minOutputAmount,
            msg.sender,
            deadline
        );

        // Sanity check, already checked by Swappa. Can be removed to save gas if needed.
        require(outputAmount >= minOutputAmount, "Insufficient output amount!");

        emit Swap(
            msg.sender,
            inputToken,
            path[path.length - 1],
            inputAmount,
            outputAmount,
            fee
        );
    }
}
