import { ethers } from "hardhat";
import { Contract } from "ethers";
import { wei } from "./utils";

export async function setupFarmBot(
  token0Contract: Contract,
  lpTokenAddress: string,
  routerContract: Contract
) {
  // ommit second address because it's being used as user account?
  const [deployer, , reserve] = await ethers.getSigners();

  const revoBountyFactory = await ethers.getContractFactory("MockRevoFees");
  const feeContract = await revoBountyFactory.deploy();

  const erc20Factory = await ethers.getContractFactory("MockERC20");
  const rewardsToken0Contract = await erc20Factory.deploy(
    "Mock rewards token 0",
    "RWD0",
    wei(1000)
  );
  const rewardsToken1Contract = await erc20Factory.deploy(
    "Mock rewards token 1",
    "RWD1",
    wei(1000)
  );
  const rewardsToken2Contract = await erc20Factory.deploy(
    "Mock rewards token 2",
    "RWD2",
    wei(1000)
  );
  await rewardsToken0Contract.deployed();
  await rewardsToken1Contract.deployed();
  await rewardsToken2Contract.deployed();

  const stakingRewardsFactory = await ethers.getContractFactory(
    "MockMoolaStakingRewards"
  );
  const stakingRewardsContract = await stakingRewardsFactory.deploy(
    token0Contract.address, // rewards token
    [
      rewardsToken0Contract.address,
      rewardsToken1Contract.address,
      rewardsToken2Contract.address,
    ],
    lpTokenAddress
  );

  const farmBotFactory = await ethers.getContractFactory("RevoUbeswapFarmBot");
  const farmBot = await farmBotFactory.deploy(
    deployer.address,
    reserve.address,
    stakingRewardsContract.address,
    lpTokenAddress,
    feeContract.address,
    [
      rewardsToken0Contract.address,
      rewardsToken1Contract.address,
      rewardsToken2Contract.address,
    ],
    routerContract.address,
    routerContract.address,
    "FP"
  );
  await farmBot.deployed();

  return {
    farmBot,
    stakingRewardsContract,
  };
}
