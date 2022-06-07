// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/ISwappaRouter.sol";

contract GaslessSwap is Ownable {
    address beneficiary;
    ISwappaRouterV1 private swappaRouter;

    event Swap(
        address indexed userAddress,
        address indexed token,
        uint256 inputValue,
        uint256 outputValue
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

    function swap(
        address token,
        address owner,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        address[] calldata path,
        address[] calldata pairs,
        bytes[] calldata extras,
        uint256 minOutputAmount
    ) external {
        uint256 gasToUse = gasleft();
        IERC20Permit(token).permit(
            owner,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
        ERC20(token).transferFrom(owner, address(this), value);

        ERC20(token).approve(address(swappaRouter), value);
        swappaRouter.swapExactInputForOutput(
            path,
            pairs,
            extras,
            value,
            minOutputAmount,
            address(this),
            deadline
        );
        ERC20 outputToken = ERC20(path[path.length - 1]);
        uint256 outputAmount = outputToken.balanceOf(address(this));

        // Refund the max gas cost.
        uint256 gasCost = tx.gasprice * gasToUse;
        require(outputToken.transfer(beneficiary, gasCost));
        require(
            outputToken.transfer(owner, outputToken.balanceOf(address(this)))
        );

        emit Swap(owner, token, value, outputAmount);
    }
}
