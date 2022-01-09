import { BigNumber } from "@ethersproject/bignumber";
import { expect } from "chai";
import { ethers } from "hardhat";
import { awaitTx } from "./utils";

const decimals = BigNumber.from(10).pow(18);

function wei(value: number) {
  return BigNumber.from(value).mul(decimals);
}

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
    await awaitTx(featureVoting.addFeature("Feat 1"));
    await awaitTx(featureVoting.addFeature("Feat 2"));

    const addr1Voting = featureVoting.connect(addr1);

    await awaitTx(
      energy.connect(addr1).approve(featureVoting.address, wei(100))
    );
    await awaitTx(addr1Voting.vote(0, wei(2)));
    await awaitTx(addr1Voting.vote(1, wei(1)));

    expect(await energy.balanceOf(addr1.address)).to.eq(wei(2));

    // Not enough balance, should revert
    await expect(addr1Voting.vote(1, wei(3))).to.be.reverted;

    await awaitTx(featureVoting.featureFinished(1));

    // Feature inactive, should revert
    await expect(addr1Voting.vote(1, wei(1))).to.be.reverted;

    await awaitTx(featureVoting.setActive(0, false));

    // Feature inactive, should revert
    await expect(addr1Voting.vote(0, wei(1))).to.be.reverted;

    await awaitTx(featureVoting.setActive(0, true));
    await awaitTx(addr1Voting.vote(0, wei(1)));

    const feature0 = await featureVoting.features(0);
    expect(feature0.votes).to.eq(wei(3));
    expect(feature0.finished).to.eq(false);
    expect(feature0.active).to.eq(true);

    const feature1 = await featureVoting.features(1);
    expect(feature1.votes).to.eq(wei(1));
    expect(feature1.finished).to.eq(true);
    expect(feature1.active).to.eq(false);
  });
});
