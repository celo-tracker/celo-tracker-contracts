import { ethers } from "hardhat";
import { awaitTx, wei } from "./utils";

export async function setupMiniChef(lpToken: string, lpToken2?: string) {
  const erc20Factory = await ethers.getContractFactory("MockERC20");
  const sushi = await erc20Factory.deploy("Mock Sushi", "SUSHI", wei(1000));
  const miniChefFactory = await ethers.getContractFactory("MiniChefV2");
  const miniChef = await miniChefFactory.deploy(sushi.address);
  await miniChef.deployed();

  await awaitTx(
    miniChef.add(
      100,
      lpToken,
      "0x0000000000000000000000000000000000000000" // rewarder address
    )
  );
  if (lpToken2) {
    await awaitTx(
      miniChef.add(
        100,
        lpToken2,
        "0x0000000000000000000000000000000000000000" // rewarder address
      )
    );
  }
  return {
    sushi,
    miniChef,
  };
}
