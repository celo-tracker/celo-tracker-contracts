// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.2;

import "../../interfaces/uniswap/IUniswapV2Factory.sol";
import "./UniswapV2Pair.sol";

contract UniswapV2Factory is IUniswapV2Factory {
  address public override feeTo;
  address public override feeToSetter;
  address public override migrator;

  mapping(address => mapping(address => address)) public override getPair;
  address[] public override allPairs;

  constructor(address _feeToSetter) {
    feeToSetter = _feeToSetter;
  }

  function allPairsLength() external view override returns (uint256) {
    return allPairs.length;
  }

  function createPair(address tokenA, address tokenB)
    external
    override
    returns (address pair)
  {
    require(tokenA != tokenB, "UniswapV2: IDENTICAL_ADDRESSES");
    (address token0, address token1) = tokenA < tokenB
      ? (tokenA, tokenB)
      : (tokenB, tokenA);
    require(token0 != address(0), "UniswapV2: ZERO_ADDRESS");
    require(getPair[token0][token1] == address(0), "UniswapV2: PAIR_EXISTS"); // single check is sufficient
    UniswapV2Pair pairContract = new UniswapV2Pair();
    pair = address(pairContract);
    pairContract.initialize(token0, token1);
    getPair[token0][token1] = pair;
    getPair[token1][token0] = pair; // populate mapping in the reverse direction
    allPairs.push(pair);
    emit PairCreated(token0, token1, pair, allPairs.length);
  }

  function setFeeTo(address _feeTo) external override {
    require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN");
    feeTo = _feeTo;
  }

  function setMigrator(address _migrator) external override {
    require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN");
    migrator = _migrator;
  }

  function setFeeToSetter(address _feeToSetter) external override {
    require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN");
    feeToSetter = _feeToSetter;
  }
}
