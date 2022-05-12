// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Energy is ERC20, ERC20Burnable, AccessControl {
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
  bytes32 public constant SPENDER_ROLE = keccak256("SPENDER_ROLE");

  constructor() ERC20("Energy", "NRG") {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
    _mint(to, amount);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public virtual override returns (bool) {
    _transfer(sender, recipient, amount);

    if (hasRole(SPENDER_ROLE, _msgSender())) {
      return true;
    }

    uint256 currentAllowance = allowance(sender, _msgSender());
    require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
    unchecked {
      _approve(sender, _msgSender(), currentAllowance - amount);
    }

    return true;
  }
}
