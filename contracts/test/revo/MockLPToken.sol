// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "../MockERC20.sol";

contract MockLPToken is MockERC20 {
  address public token0;
  address public token1;

  constructor(
    string memory name_,
    string memory symbol_,
    address _token0,
    address _token1,
    uint256 supply
  ) MockERC20(name_, symbol_, supply) {
    token0 = _token0;
    token1 = _token1;
  }
}
