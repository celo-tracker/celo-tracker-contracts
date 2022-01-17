// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.2;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}