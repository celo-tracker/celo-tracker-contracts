import { expect } from "chai";
import { BigNumber, Contract } from "ethers";
import { ethers } from "hardhat";
import { awaitTx } from "./utils";

describe("ERC20 Balances", function () {
  let token0: Contract;
  let token1: Contract;
  let erc20Balances: Contract;

  beforeEach(async function () {
    const erc20Factory = await ethers.getContractFactory("MockERC20");
    token0 = await erc20Factory.deploy("Token 0", "T0", 100);
    token1 = await erc20Factory.deploy("Token 1", "T1", 100);

    const ERC20BalancesFactory = await ethers.getContractFactory(
      "ERC20Balances"
    );
    erc20Balances = await ERC20BalancesFactory.deploy();

    await token0.deployed();
    await token1.deployed();
    await erc20Balances.deployed();
  });

  it("returns the right values", async function () {
    const [owner, account1] = await ethers.getSigners();
    await awaitTx(token0.transfer(account1.address, 5));

    const ownerBalances = await erc20Balances.getBalances(owner.address, [
      token0.address,
      token1.address,
    ]);
    expect(ownerBalances.length).to.eq(2);
    expect(ownerBalances[0]).to.eq(95);
    expect(ownerBalances[1]).to.eq(100);

    const account1Balances = await erc20Balances.getBalances(account1.address, [
      token0.address,
      token1.address,
    ]);
    expect(account1Balances.length).to.eq(2);
    expect(account1Balances[0]).to.eq(5);
    expect(account1Balances[1]).to.eq(0);
  });
});
