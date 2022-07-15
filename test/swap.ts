import { expect } from "chai";
import { Contract } from "ethers";
import { ethers } from "hardhat";
import { setupUniswapPools } from "./uniswap";
import { awaitTx, wei } from "./utils";

describe("Swap", function () {
  let token0: Contract, token1: Contract, swappa: Contract, swapper: Contract;

  beforeEach(async function () {
    ({ token0, token1 } = await setupUniswapPools());

    const [, beneficiary] = await ethers.getSigners();

    const swappaFactory = await ethers.getContractFactory("MockSwappa");
    swappa = await swappaFactory.deploy(token0.address, token1.address);
    await swappa.deployed();

    const swapperFactory = await ethers.getContractFactory("SwapWithFee");
    swapper = await swapperFactory.deploy(
      swappa.address,
      beneficiary.address,
      1500
    );
    await swapper.deployed();

    await awaitTx(token0.transfer(swappa.address, wei(1000)));
    await awaitTx(token1.transfer(swappa.address, wei(1000)));
  });

  it("swaps and charges a fee", async function () {
    const [owner, beneficiary] = await ethers.getSigners();

    const token0InitialBalance = await token0.balanceOf(owner.address);
    const token1InitialBalance = await token1.balanceOf(owner.address);

    await awaitTx(token0.approve(swapper.address, wei(100)));
    await awaitTx(
      swapper.swap(
        [token0.address, token1.address],
        [],
        [],
        wei(100),
        0,
        owner.address,
        (Date.now() / 1000 + 60 * 10).toFixed(0)
      )
    );

    // ASSERTIONS
    expect(await token0.balanceOf(owner.address)).to.eq(
      token0InitialBalance.sub(wei(100))
    );
    expect(await token1.balanceOf(owner.address)).to.eq(
      token1InitialBalance.add(wei(100).sub(wei(15, 100)))
    );
    expect(await token0.balanceOf(beneficiary.address)).to.eq(wei(15, 100));
  });
});
