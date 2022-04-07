// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IRevoFees.sol";

contract MockRevoFees is IRevoFees {
  TokenAmount[] bonuses;

  uint256 compounderFeeAmount;

  function setCompounderFee(uint256 _compounderFee) external {
    compounderFeeAmount = _compounderFee;
  }

  function compounderFee(uint256 _interestAccrued)
    external
    view
    override
    returns (uint256)
  {
    return compounderFeeAmount;
  }

  function compounderBonus(TokenAmount memory _interestAccrued)
    external
    view
    override
    returns (TokenAmount[] memory)
  {
    return new TokenAmount[](0);
  }

  uint256 reserveFeeAmount;

  function setReserveFee(uint256 _reserveFee) external {
    reserveFeeAmount = _reserveFee;
  }

  function reserveFee(uint256 _interestAccrued)
    external
    view
    override
    returns (uint256)
  {
    return reserveFeeAmount;
  }

  uint256 withdrawalFeeNumerator = 25;
  uint256 withdrawalFeeDenominator = 10000;

  function setWithdrawalFee(uint256 _feeNumerator, uint256 _feeDenominator)
    public
  {
    withdrawalFeeNumerator = _feeNumerator;
    withdrawalFeeDenominator = _feeDenominator;
  }

  function withdrawalFee(
    uint256 interestEarnedNumerator,
    uint256 interestEarnedDenominator
  )
    external
    view
    override
    returns (uint256 feeNumerator, uint256 feeDenominator)
  {
    feeNumerator = withdrawalFeeNumerator;
    feeDenominator = withdrawalFeeDenominator;
  }

  function issueCompounderBonus(address recipient) external override {
    return;
  }
}
