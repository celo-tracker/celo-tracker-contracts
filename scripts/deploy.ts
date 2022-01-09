import { ethers } from "hardhat";
import { wei } from "../test/utils";

const dailyReward = wei(5);

// Deprecated, deployed using hardhat-deploy script instead (see deploy folder in root)
async function main() {
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

  console.log("Deployed contracts:");
  console.log("Energy:", energy.address);
  console.log("Energy Rewarder:", energyRewarder.address);
  console.log("Feature Voting:", featureVoting.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
