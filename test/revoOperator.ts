import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { Contract, ContractFactory } from "ethers";
import { ethers } from "hardhat";
import { setupUniswapPools } from "./uniswap";
import { awaitTx, wei } from "./utils";
import { setupFarmBot } from "./revoSetup";

describe("Revo operator", function () {
  let token0: Contract,
    token1: Contract,
    router: Contract,
    factory: Contract,
    lpToken: string,
    account1: SignerWithAddress,
    operator: Contract,
    pairFactory: ContractFactory,
    lpTokenContract: Contract,
    farmBot: Contract,
    reserve: SignerWithAddress,
    owner: SignerWithAddress;

  beforeEach(async function () {
    ({ token0, token1, router, factory, lpToken, owner } =
      await setupUniswapPools());

    console.log(lpToken, "lpToken");

    const rewarderFactory = await ethers.getContractFactory("EmptyRewarder");
    const rewarder = await rewarderFactory.deploy();
    await rewarder.deployed();

    [, reserve, account1] = await ethers.getSigners();
    pairFactory = await ethers.getContractFactory("UniswapV2Pair");

    farmBot = await setupFarmBot(owner, reserve, token0, lpToken, router);

    lpTokenContract = pairFactory.attach(lpToken);

    const revoOperatorFactory = await ethers.getContractFactory("RevoOperator");
    operator = await revoOperatorFactory.deploy(
      router.address,
      factory.address,
      farmBot.address,
      rewarder.address
    );
    await operator.deployed();
  });

  it("zaps into revo using one token", async function () {
    await awaitTx(token0.transfer(account1.address, wei(10)));
    await awaitTx(token0.connect(account1).approve(operator.address, wei(10)));
    await awaitTx(
      operator
        .connect(account1)
        .swapAndZapIn(token0.address, token1.address, wei(10), wei(99, 10), 98)
    );

    // ASSERTIONS

    // Operator doesn't have any leftovers.
    expect(await token0.balanceOf(operator.address)).to.eq(0);
    expect(await token1.balanceOf(operator.address)).to.eq(0);
    expect(await lpTokenContract.balanceOf(operator.address)).to.eq(0);

    // Revo's farm bot has a balance of lp token
    /* const lpTokenBalance = await lpTokenContract.balanceOf(farmBot.address);
    expect(lpTokenBalance).to.gt(0); */

    // Account 1 has a balance of fp token in bot.
    const fpTokenBalance = await farmBot.balanceOf(account1.address);
    expect(fpTokenBalance).to.gt(0);
  });

  /* it("zaps into ubeswap using two tokens", async function () {
    await awaitTx(token0.transfer(account1.address, wei(5)));
    await awaitTx(token1.transfer(account1.address, wei(10)));
    await awaitTx(token0.connect(account1).approve(operator.address, wei(5)));
    await awaitTx(token1.connect(account1).approve(operator.address, wei(10)));
    await awaitTx(
      operator
        .connect(account1)
        .zapInWithUbeswap(token0.address, token1.address, wei(5), wei(10), 98)
    );

    // ASSERTIONS

    const pairFactory = await ethers.getContractFactory("UniswapV2Pair");
    const lpTokenContract = await pairFactory.attach(lpToken);

    // Operator doesn't have any leftovers.
    expect(await token0.balanceOf(operator.address)).to.eq(0);
    expect(await token1.balanceOf(operator.address)).to.eq(0);
    expect(await lpTokenContract.balanceOf(operator.address)).to.eq(0);

    // Account 1 has a balance of lp token.
    const lpTokenBalance = await lpTokenContract.balanceOf(account1.address);
    expect(lpTokenBalance).to.gt(0);
  }); */
});
