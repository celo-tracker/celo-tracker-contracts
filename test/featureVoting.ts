import { expect } from "chai";
import { ethers } from "hardhat";
import { awaitTx, wei } from "./utils";

describe("Feature Voting", function () {
  it("Should behave as expected", async function () {
    const dailyReward = wei(5);
    const Energy = await ethers.getContractFactory("Energy");
    const energy = await Energy.deploy();
    await energy.deployed();
    const EnergyRewarder = await ethers.getContractFactory("EnergyRewarder");
    const energyRewarder = await EnergyRewarder.deploy(
      dailyReward,
      energy.address
    );
    const FeatureVoting = await ethers.getContractFactory("FeatureVoting");
    const featureVoting = await FeatureVoting.deploy(energy.address);
    await energyRewarder.deployed();
    await featureVoting.deployed();

    const [owner, addr1] = await ethers.getSigners();

    // ---------- ENERGY REWARDER ----------
    const minterRole = await energy.MINTER_ROLE();
    const addr1Rewarder = energyRewarder.connect(addr1);

    // Minting should fail since energy rewarder is not yet a minter
    await expect(addr1Rewarder.mintDailyReward()).to.be.reverted;

    await awaitTx(energy.grantRole(minterRole, energyRewarder.address));
    await awaitTx(addr1Rewarder.mintDailyReward());

    expect(await energy.balanceOf(addr1.address)).to.eq(dailyReward);
    expect(await energy.balanceOf(owner.address)).to.eq(0);

    // Minting twice in the same day is not allowed.
    await expect(addr1Rewarder.mintDailyReward()).to.be.reverted;

    // ---------- FEATURE VOTING ----------
    const addr1Voter = featureVoting.connect(addr1);
    // Without approval it fails.
    await expect(addr1Voter.addFeature("Feat", wei(1))).to.be.reverted;

    // Makeit a whitelisted spender
    const spenderRole = await energy.SPENDER_ROLE();
    await awaitTx(energy.grantRole(spenderRole, featureVoting.address));

    await awaitTx(addr1Voter.addFeature("Feat 1", wei(1)));
    await awaitTx(addr1Voter.addFeature("Feat 2", wei(1)));

    await awaitTx(addr1Voter.vote(0, wei(2)));
    await awaitTx(addr1Voter.vote(1, wei(1)));

    const features = await featureVoting.getFeatures();
    expect(features.length).to.eq(2);
  });
});
