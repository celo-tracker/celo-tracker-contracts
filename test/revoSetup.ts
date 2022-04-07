import { ethers } from "hardhat";

export async function setupFarmBot() {
  // ? ommit the first two because they are being used by other contracts?
  const [, , deployer, reserve] = await ethers.getSigners();

  const revoBountyFactory = await ethers.getContractFactory("MockRevoFees");
  const feeContract = await revoBountyFactory.deploy();

  const erc20Factory = await ethers.getContractFactory("MockERC20");

  const rewardsToken0Contract = await erc20Factory.deploy(
    "Mock rewards token 0",
    "RWD0"
  );
  const rewardsToken1Contract = await erc20Factory.deploy(
    "Mock rewards token 1",
    "RWD1"
  );
  const rewardsToken2Contract = await erc20Factory.deploy(
    "Mock rewards token 2",
    "RWD2"
  );

  const token0Contract = await erc20Factory.deploy("Mock token 0", "T0");
  const token1Contract = await erc20Factory.deploy("Mock token 1", "T1");

  const lpFactory = await ethers.getContractFactory("MockLPToken");
  const lpTokenContract = await lpFactory.deploy(
    "Mock staking token", // name
    "LP", // symbol
    token0Contract.address,
    token1Contract.address
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
  return await farmBot.deployed();
}
