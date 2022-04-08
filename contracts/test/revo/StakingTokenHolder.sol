//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./IRevoFees.sol";

/**
 * StakingTokenHolder is an abstract base class that can be used to implement Revo farm bots on top
 * of arbitrary sources of yield. These sources of yield come from staking some ERC20 token
 * (the "staking token") into a contract.
 *
 * Minimally, subclasses must implement the _deposit and _withdraw, methods that
 * deposit/withdraw an amount of the staked token into the "farm". This will
 * result in a farm bot that does not auto-compound yield; it acts only as "storage" for a
 * user's staking token.
 *
 * Notably, this class does not contain a virtual "compound" function; this is because depending
 * on the implementation, a function repsonsible for compounding the farm bot's staked position may
 * require different arguments from the caller.
 *
 * This class also does not make any assumptions about how yield rewards are converted back into
 * the staking token. For example, this may require a series of swaps and minting a liquidity token ("LP"),
 * or for a single-staking source of yield that issues the staking token itself as a reward, nothing at all.
 * Since swapping is a common scenario however, this class contains tools for controlling slippage tolerance.
 *
 * For convenience and ease of naming, the staking token is referred to as "LP" throughout the class,
 * although in reality, it may not represent an actual liquidity token.
 **/
abstract contract StakingTokenHolder is ERC20, AccessControl, Pausable {
  using SafeERC20 for IERC20;

  event FeesUpdated(address indexed by, address indexed to);
  event ReserveUpdated(address indexed by, address indexed reserveAddress);
  event SlippageUpdated(
    address indexed by,
    uint256 numerator,
    uint256 denominator
  );
  event Deposit(address indexed by, uint256 lpAmount);
  event Withdraw(address indexed by, uint256 lpAmount, uint256 fee);
  event Compound(
    address indexed by,
    uint256 lpStaked,
    uint256 newLPTotalBalance,
    uint256 compounderFeeAmount,
    uint256 reserveFeeAmount
  );
  event GrantRole(
    address indexed by,
    address indexed newRoleRecipient,
    bytes32 role
  );

  modifier ensure(uint256 deadline) {
    require(deadline >= block.timestamp, "FarmBot: EXPIRED");
    _;
  }

  bytes32 public constant COMPOUNDER_ROLE = keccak256("COMPOUNDER_ROLE");

  uint256 public lpTotalBalance; // total number of LP tokens owned by Farm Bot

  IERC20 public stakingToken; // LP that's being staked

  // fractional increase of LP balance last time compound was called. Used to calculate withdrawal fee.
  uint256 public interestEarnedNumerator;
  uint256 public interestEarnedDenominator = 10000;

  // Acceptable slippage when minting LP; can be updated by admin
  uint256 public slippageNumerator = 99;
  uint256 public slippageDenominator = 100;

  // Configurable fees contract. Determines:
  //  - "compounder fee" for calling compound on behalf of farm investors.
  //  - "reserve fee" sent to reserve
  //  - "compounder bonus" (paid by reserve) for calling compound
  //  - "withdrawal fee" for withdrawing (necessary for security, guaranteed <= 0.25%)
  //  Note that compounder fees + reserve fees are "performance fees", meaning they are charged only on earnings.
  //  Performance fees are guaranteed to be at most 4%, the current standard, and should be much less.
  IRevoFees public revoFees;
  uint256 public constant maxPerformanceFeeNumerator = 40;
  uint256 public constant maxPerformanceFeeDenominator = 1000;
  uint256 public constant maxWithdrawalFeeNumerator = 25;
  uint256 public constant maxWithdrawalFeeDenominator = 10000;

  address public reserveAddress;

  constructor(
    address _owner,
    address _reserveAddress,
    address _stakingToken,
    address _revoFees,
    string memory _symbol
  ) ERC20("Revo FP Token", _symbol) {
    revoFees = IRevoFees(_revoFees);
    stakingToken = IERC20(_stakingToken);
    reserveAddress = _reserveAddress;

    _setupRole(DEFAULT_ADMIN_ROLE, _owner);
    emit GrantRole(msg.sender, _owner, DEFAULT_ADMIN_ROLE);
  }

  function grantRole(bytes32 role, address account)
    public
    virtual
    override
    onlyRole(getRoleAdmin(role))
  {
    super.grantRole(role, account);
    emit GrantRole(msg.sender, account, role);
  }

  function updateReserveAddress(address _reserveAddress)
    external
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    require(_reserveAddress != address(0), "Cannot set reserve address to 0");
    reserveAddress = _reserveAddress;
    emit ReserveUpdated(msg.sender, _reserveAddress);
  }

  function updateFees(address _revoFees) external onlyRole(DEFAULT_ADMIN_ROLE) {
    revoFees = IRevoFees(_revoFees);
    emit FeesUpdated(msg.sender, _revoFees);
  }

  function updateSlippage(
    uint256 _slippageNumerator,
    uint256 _slippageDenominator
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    slippageNumerator = _slippageNumerator;
    slippageDenominator = _slippageDenominator;
    emit SlippageUpdated(msg.sender, _slippageNumerator, _slippageDenominator);
  }

  function getFpAmount(uint256 _lpAmount) public view returns (uint256) {
    if (lpTotalBalance == 0) {
      return _lpAmount;
    } else {
      return (_lpAmount * totalSupply()) / lpTotalBalance;
    }
  }

  function getLpAmount(uint256 _fpAmount) public view returns (uint256) {
    if (totalSupply() == 0) {
      return 0;
    } else {
      return (_fpAmount * lpTotalBalance) / totalSupply();
    }
  }

  function deposit(uint256 _lpAmount) external whenNotPaused {
    bool transferSuccess = stakingToken.transferFrom(
      msg.sender,
      address(this),
      _lpAmount
    );
    require(transferSuccess, "Transfer failed, aborting deposit");

    uint256 _fpAmount = this.getFpAmount(_lpAmount);
    _mint(msg.sender, _fpAmount);
    lpTotalBalance += _lpAmount;
    _deposit(_lpAmount);
    emit Deposit(msg.sender, _lpAmount);
  }

  function withdrawAll() external {
    require(balanceOf(msg.sender) > 0, "Cannot withdraw zero balance");
    uint256 _lpAmount = getLpAmount(balanceOf(msg.sender));
    withdraw(_lpAmount);
  }

  function withdraw(uint256 _lpAmount) public {
    uint256 _fpAmount = this.getFpAmount(_lpAmount);
    require(
      balanceOf(msg.sender) >= _fpAmount,
      "Cannot withdraw more than the total balance of the owner"
    );

    uint256 tokenBalance = stakingToken.balanceOf(address(this));
    if (_lpAmount > tokenBalance) {
      _withdraw(_lpAmount - tokenBalance);
    }

    // fee
    (uint256 feeNumerator, uint256 feeDenominator) = revoFees.withdrawalFee(
      interestEarnedNumerator,
      interestEarnedDenominator
    );
    uint256 _withdrawalFee = (feeNumerator * _lpAmount) / feeDenominator;
    uint256 _maxWithdrawalFee = (maxPerformanceFeeNumerator * _lpAmount) /
      maxPerformanceFeeDenominator;
    if (_withdrawalFee > _maxWithdrawalFee) {
      // guarantee the max fee
      _withdrawalFee = _maxWithdrawalFee;
    }

    bool feeSuccess = stakingToken.transfer(reserveAddress, _withdrawalFee);
    require(feeSuccess, "Fee failed, aborting withdrawal");
    bool transferSuccess = stakingToken.transfer(
      msg.sender,
      _lpAmount - _withdrawalFee
    );
    require(transferSuccess, "Transfer failed, aborting withdrawal");
    _burn(msg.sender, _fpAmount);
    lpTotalBalance -= _lpAmount;
    emit Withdraw(msg.sender, _lpAmount, _withdrawalFee);
  }

  // Abstract method for depositing LP into a farm
  function _deposit(uint256 _lpAmount) internal virtual;

  // Abstract method for withdrawing LP from a farm
  function _withdraw(uint256 _lpAmount) internal virtual;

  // Convenience method for subclasses
  function issuePerformanceFeesAndBonus()
    internal
    whenNotPaused
    returns (
      uint256 lpEarnings,
      uint256 compounderFee,
      uint256 reserveFee
    )
  {
    // send fees to compounder and reserve
    uint256 lpBalance = stakingToken.balanceOf(address(this));
    compounderFee = revoFees.compounderFee(lpBalance);
    reserveFee = revoFees.reserveFee(lpBalance);
    require(
      compounderFee + reserveFee <=
        (lpBalance * maxPerformanceFeeNumerator) / maxPerformanceFeeDenominator,
      "Performance fee too high"
    );
    bool compounderFeeSuccess = stakingToken.transfer(
      msg.sender,
      compounderFee
    );
    bool reserveFeeSuccess = stakingToken.transfer(reserveAddress, reserveFee);
    require(compounderFeeSuccess && reserveFeeSuccess, "Sending fees failed");

    // Send compounder bonus

    revoFees.issueCompounderBonus(msg.sender);

    lpEarnings = lpBalance - compounderFee - reserveFee;
    return (lpEarnings, compounderFee, reserveFee);
  }

  // Convenience method for subclasses
  function updateFpWeightAndInterestRate(uint256 _lpEarnings)
    internal
    whenNotPaused
  {
    lpTotalBalance += _lpEarnings;

    interestEarnedNumerator =
      (_lpEarnings * interestEarnedDenominator) /
      lpTotalBalance;
  }

  function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
    _pause();
  }

  function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
    _unpause();

    uint256 lpBalance = stakingToken.balanceOf(address(this));
    if (lpBalance > 0) {
      _deposit(lpBalance);
    }
  }
}
