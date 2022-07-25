import { expect } from "chai";
import { ethers } from "hardhat";
import { awaitTx, wei } from "./utils";

describe("Transaction Rewarder", function () {
  it("Should behave as expected", async function () {
    const rewardForTx = wei(5);
    const lastBlock = await ethers.provider.getBlock("latest");
    const EnergyFactory = await ethers.getContractFactory("Energy");
    const energy = await EnergyFactory.deploy();
    await energy.deployed();
    const RewarderFactory = await ethers.getContractFactory("Rewarder");
    const rewarder = await RewarderFactory.deploy(energy.address);
    const MockSwapFactory = await ethers.getContractFactory("MockSwap");
    const mockSwap = await MockSwapFactory.deploy(rewarder.address);
    await mockSwap.deployed();

    const [owner, addr1] = await ethers.getSigners();

    const minterRole = await energy.MINTER_ROLE();
    await awaitTx(energy.grantRole(minterRole, rewarder.address));
    await awaitTx(
      rewarder
        .connect(owner)
        .addObjective(
          rewardForTx,
          mockSwap.address,
          lastBlock.number,
          lastBlock.number + 10
        )
    );
    const objectives = await rewarder.getObjectives();
    expect(objectives.length).to.eq(1);

    const swapReceipt = await awaitTx(mockSwap.connect(addr1).swap());
    const event = swapReceipt.events?.find((e) => e.event === "RewardForSwap");
    const interactionIndex = event?.args?.[1].toString() ?? "";
    const objectiveIndex = await rewarder.getObjectiveByOrigin(
      mockSwap.address
    );

    await awaitTx(
      rewarder
        .connect(addr1)
        .claimReward(
          interactionIndex,
          objectiveIndex.toString(),
          mockSwap.address,
          addr1.address
        )
    );
    expect(await energy.balanceOf(addr1.address)).to.eq(rewardForTx);
    expect(await energy.balanceOf(owner.address)).to.eq(0);

    // check for errors(to.be.reverted): cuando no hay un objective, cuando el block no está dentro del rango.
  });
});
