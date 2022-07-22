// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface LpToken is IERC20 {
    function minter() external view returns (address);
}
