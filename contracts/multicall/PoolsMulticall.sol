// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PoolsMulticall is Ownable {
    struct UserPool {
        address pool;
        uint256 balance;
        uint256 poolShare; // in wei.
    }

    function getPoolsInfo(address[] memory poolAddresses, address user)
        external
        view
        returns (UserPool[] memory pools)
    {
        pools = new UserPool[](poolAddresses.length);

        for (uint256 i = 0; i < poolAddresses.length; i++) {
            uint256 balance = ERC20(poolAddresses[i]).balanceOf(user);
            uint256 totalSupply = ERC20(poolAddresses[i]).totalSupply();
            uint256 share = (balance * 10**18) / totalSupply;
            pools[i] = UserPool(poolAddresses[i], balance, share);
        }
    }

    // Shouldn't hold funds, just in case.
    function recoverFunds(address to, address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(IERC20(token).transfer(to, balance), "Token recovery failed");
    }

    function min(uint256 a, uint256 b) public pure returns (uint256) {
        return a < b ? a : b;
    }
}
