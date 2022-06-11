// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Balances is Ownable {
    function getBalances(address userAddress, address[] calldata tokenAddresses)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory balances = new uint256[](tokenAddresses.length);

        for (uint256 index = 0; index < tokenAddresses.length; index++) {
            balances[index] = ERC20(tokenAddresses[index]).balanceOf(
                userAddress
            );
        }

        return balances;
    }
}
