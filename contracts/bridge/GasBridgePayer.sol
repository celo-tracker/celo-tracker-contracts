// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/wormhole/IWormhole.sol";

/// This contract is part of a Gas Purchase system. Users can pay in one network and receive gas tokens in a
/// different one.
/// The payer receives messages sent from the Cashier and releases gas tokens to the recipient that comes in
/// the message.
contract GasBridgePayer is Ownable {
    event GasSent(
        address indexed recipient,
        uint256 paymentAmount,
        uint64 sequence
    );
    event SetPaymentAmount(uint256 paymentAmount);
    event SetCashier(uint16 indexed chainId, bytes32 cashier);

    /// Which cashiers we accept messages from in each network.
    mapping(uint16 => bytes32) public cashiersByChainId;
    /// For each (emitter, sequence), was the transaction already processed?
    mapping(bytes32 => mapping(uint64 => bool)) public transactionMade;
    IWormhole wormhole;
    /// How many gas tokens to release when receiving valid messages.
    uint256 public paymentAmount;

    constructor(IWormhole _wormhole, uint256 _paymentAmount) {
        wormhole = _wormhole;
        paymentAmount = _paymentAmount;
    }

    /// When receiving a message, we need to make sure it's a valid one and we haven't released
    /// gas tokens from it yet and send gas tokens to the recipient if checks pass.
    /// @param encodedVm The message that was emitted in the origin network.
    function sendGas(bytes memory encodedVm) external payable {
        (IWormhole.VM memory vm, bool valid, string memory reason) = wormhole
            .parseAndVerifyVM(encodedVm);

        require(valid, reason);
        require(
            cashiersByChainId[vm.emitterChainId] == vm.emitterAddress,
            "Invalid emitter"
        );

        require(
            !transactionMade[vm.emitterAddress][vm.sequence],
            "Gas already sent"
        );
        transactionMade[vm.emitterAddress][vm.sequence] = true;

        (address recipient, uint16 destinationChain) = decodePayload(
            vm.payload
        );
        require(
            destinationChain == wormhole.chainId(),
            "Invalid destination chain"
        );

        (bool sent, ) = recipient.call{value: paymentAmount}("");
        require(sent, "Insufficient balance");

        emit GasSent(recipient, paymentAmount, vm.sequence);
    }

    function decodePayload(bytes memory payload)
        public
        pure
        returns (address recipient, uint16 destinationChain)
    {
        (bytes32 recipientBytes, uint16 chainId) = abi.decode(
            payload,
            (bytes32, uint16)
        );
        recipient = addressFromBytes32(recipientBytes);
        destinationChain = chainId;
    }

    function addressFromBytes32(bytes32 original)
        public
        pure
        returns (address)
    {
        return address(uint160(uint256(original)));
    }

    function setChainIdCashier(uint16 chainId, bytes32 cashier)
        external
        onlyOwner
    {
        cashiersByChainId[chainId] = cashier;
        emit SetCashier(chainId, cashier);
    }

    function setPaymentAmount(uint256 _paymentAmount) external onlyOwner {
        paymentAmount = _paymentAmount;
        emit SetPaymentAmount(_paymentAmount);
    }

    /// Shouldn't be necessary, here just in case of emergency.
    function recoverFunds(address to, address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(IERC20(token).transfer(to, balance), "Token recovery failed");
    }

    /// Shouldn't be necessary, here just in case of emergency.
    function recoverNativeToken(address to) external onlyOwner {
        (bool sent, ) = to.call{value: address(this).balance}("");
        require(sent, "Native token recovery failed");
    }

    receive() external payable {}
}
