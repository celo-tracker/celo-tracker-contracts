// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IRevoFarmBot is IERC20 {
  function deposit(uint256 _lpAmount) external;
}
