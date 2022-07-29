import { ethers } from "hardhat";
import { awaitTx } from "../test/utils";

const PATH_FINDER = "0x62d60427307BB0208eB0869bDBf343D8D108d8ab";

export async function pathFinder() {
  const factory = await ethers.getContractFactory("PathFinder");
  const pathFinder = await factory.attach(PATH_FINDER);

  await awaitTx(
    pathFinder.setOwner("0x7a6daee82f0A5141fd9e5443caA5eaa39147415f", true)
  );
}
