import { ethers } from "hardhat";
import { Contract } from "ethers";

export async function setupOperator(
  router: Contract,
  factory: Contract,
  miniChef: Contract
) {
  const rewarderFactory = await ethers.getContractFactory("EmptyRewarder");
  const rewarder = await rewarderFactory.deploy();
  await rewarder.deployed();

  const sushiOperatorFactory = await ethers.getContractFactory("SushiOperator");
  const sushiOperator = await sushiOperatorFactory.deploy(
    router.address,
    factory.address,
    miniChef.address,
    rewarder.address
  );
  await sushiOperator.deployed();

  const ubeswapOperatorFactory = await ethers.getContractFactory(
    "UbeswapOperator"
  );
  const ubeswapOperator = await ubeswapOperatorFactory.deploy(
    router.address,
    factory.address,
    rewarder.address
  );
  await ubeswapOperator.deployed();

  const operatorFactory = await ethers.getContractFactory("OperatorProxy");
  const operator = await operatorFactory.deploy(
    sushiOperator.address,
    ubeswapOperator.address
  );
  await operator.deployed();

  return operator;
}
