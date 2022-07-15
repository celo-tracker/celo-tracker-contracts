// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/wormhole/IWormhole.sol";

/// This contract is part of a Gas Purchase system. Users can pay in one network and receive gas tokens in a
/// different one.
/// The Cashier is responsible of charging users and emitting a message so that gas is sent to them in the
/// destination network.
contract GasBridgeCashier is Ownable {
    event SetTreasuryAddress(address indexed treasury);
    event SetGasTokenPrice(
        uint16 indexed chainId,
        address indexed token,
        uint256 price
    );

    /// How much needs to be paid in order for a message to be sent to release gas in the destination network.
    /// For each (Wormhole) chainId we store a mapping from token address to price to be charged.
    mapping(uint16 => mapping(address => uint256)) public gasTokenPrices;
    IWormhole public wormhole;
    /// Payments are sent to the treasury.
    address public treasury;

    constructor(IWormhole _wormhole, address _treasury) {
        wormhole = _wormhole;
        treasury = _treasury;
    }

    /// Checks that the token to pay is valid, charges the sender an emits a message for the detination network.
    /// @param recipient Who will receive the gas tokens in the destination network.
    /// @param destinationChain In which network will the gas token be released.
    /// @param paymentToken Which token the user will pay with
    /// @param nonce Random number up to 2^32.
    /// @return sequence a sequential number for this contract's messages.
    function sendGas(
        bytes32 recipient,
        uint16 destinationChain,
        address paymentToken,
        uint32 nonce
    ) external payable returns (uint64 sequence) {
        uint256 price = gasTokenPrices[destinationChain][paymentToken];
        require(price > 0, "Token not enabled for destination network");
        require(
            IERC20(paymentToken).transferFrom(msg.sender, treasury, price),
            "Insufficient balance"
        );

        bytes memory payload = abi.encode(recipient, destinationChain);

        sequence = wormhole.publishMessage(nonce, payload, 1);
        return sequence;
    }

    /// Sets the price of the gas tokens for a network/token combination.
    /// @param chainId Which destination network we're setting the price for.
    /// @param token Token to pay with.
    /// @param value How much of |token| will the user need to pay to get gas tokens on |chainId|.
    function setGasTokenPrice(
        uint16 chainId,
        address token,
        uint256 value
    ) external onlyOwner {
        gasTokenPrices[chainId][token] = value;
        emit SetGasTokenPrice(chainId, token, value);
    }

    function setTreasury(address _treasury) external onlyOwner {
        treasury = _treasury;
        emit SetTreasuryAddress(_treasury);
    }

    /// Shouldn't be necessary, here in case of emergency only.
    function recoverFunds(address to, address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(IERC20(token).transfer(to, balance), "Token recovery failed");
    }

    /// Shouldn't be necessary, here just in case of emergency.
    function recoverNativeToken(address to) external onlyOwner {
        (bool sent, ) = to.call{value: address(this).balance}("");
        require(sent, "Native token recovery failed");
    }
}
