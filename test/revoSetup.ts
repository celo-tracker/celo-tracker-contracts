import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { Contract } from "ethers";
import { wei } from "./utils";

/* export async function setupFarmBot() {
  // ? ommit the first two because they are being used by other contracts?
  const [, , deployer, reserve] = await ethers.getSigners();

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

  const token0Contract = await erc20Factory.deploy(
    "Mock token 0",
    "T0",
    wei(1000)
  );
  const token1Contract = await erc20Factory.deploy(
    "Mock token 1",
    "T1",
    wei(1000)
  );
  await token0Contract.deployed();
  await token1Contract.deployed();

  const lpFactory = await ethers.getContractFactory("MockLPToken");
  const lpTokenContract = await lpFactory.deploy(
    "Mock staking token", // name
    "LP", // symbol
    token0Contract.address,
    token1Contract.address,
    wei(1000)
  );

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
    lpTokenContract.address
  );

  const routerFactory = await ethers.getContractFactory("MockRouter");
  const routerContract = await routerFactory.deploy();
  await routerContract.setLPToken(lpTokenContract.address);

  const farmBotFactory = await ethers.getContractFactory("RevoUbeswapFarmBot");
  const farmBot = await farmBotFactory.deploy(
    deployer.address,
    reserve.address,
    stakingRewardsContract.address,
    lpTokenContract.address,
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
    token0: token0Contract,
    token1: token1Contract,
    router: routerContract,
    lpTokenContract,
  };
}
 */

export async function setupFarmBot(
  deployer: SignerWithAddress,
  reserve: SignerWithAddress,
  token0Contract: Contract,
  lpTokenAddress: string,
  routerContract: Contract
) {
  // ? ommit the first two because they are being used by other contracts?
  /*   const [deployer, reserve] = await ethers.getSigners();
   */

  console.log(deployer.address, "deployer");
  console.log(reserve.address, "reserve");
  console.log(token0Contract.address, "token0");
  console.log(lpTokenAddress, "lp");
  console.log(routerContract.address, "router");

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

  return farmBot;
}
