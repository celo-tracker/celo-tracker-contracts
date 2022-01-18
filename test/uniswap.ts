import { ethers } from "hardhat";
import { awaitTx, wei } from "./utils";

export async function setupUniswapPools() {
  const [owner] = await ethers.getSigners();
  const erc20Factory = await ethers.getContractFactory("MockERC20");
  const mockToken0 = await erc20Factory.deploy("Token 0", "T0", wei(100000));
  const mockToken1 = await erc20Factory.deploy("Token 1", "T1", wei(100000));
  const eth = await erc20Factory.deploy("Mock Ether", "ETH", wei(100000));
  await mockToken0.deployed();
  await mockToken1.deployed();
  await eth.deployed();
  const uniFactoryFactory = await ethers.getContractFactory("UniswapV2Factory");
  const uniRouterFactory = await ethers.getContractFactory("UniswapV2Router02");
  const factory = await uniFactoryFactory.deploy(owner.address);
  await factory.deployed();
  const router = await uniRouterFactory.deploy(factory.address, eth.address);
  await router.deployed();

  await awaitTx(mockToken0.approve(router.address, wei(50000)));
  await awaitTx(mockToken1.approve(router.address, wei(50000)));
  await awaitTx(
    router.addLiquidity(
      mockToken0.address,
      mockToken1.address,
      wei(10000),
      wei(20000),
      wei(10000),
      wei(20000),
      owner.address,
      Date.now() + 60 * 60
    )
  );
  const pair = await factory.allPairs(0);
  return {
    token0: mockToken0,
    token1: mockToken1,
    router,
    factory,
    lpToken: pair,
  };
}
