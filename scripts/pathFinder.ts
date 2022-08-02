import { ethers } from "hardhat";
import { awaitTx } from "../test/utils";
import { PairUniswapV3 } from "../typechain";

const PATH_FINDER = "0x40334830fF81a5982f4Ad08261c7653dfb61c5eD";
const PAIR_GRAPH = "0x25B1a973dd031Ae702D1ebe46AF69b660Ce1c618";

export async function pairs() {
  const factory = await ethers.getContractFactory("PairGraph");
  const graph = await factory.attach(PAIR_GRAPH);

  await awaitTx(
    graph.setOwner("0x7a6daee82f0A5141fd9e5443caA5eaa39147415f", true)
  );

  // await awaitTx(
  //   pathFinder.addPair("0x765DE816845861e75A25fCA122bb6898B8B1282a", {
  //     path: [
  //       "0x765DE816845861e75A25fCA122bb6898B8B1282a",
  //       "0x471EcE3750Da237f93B8E339c536989b8978a438",
  //     ],
  //     pairs: ["0x5ea0Edebe6a8e6ad1965BdB06A4630e8d3526360"],
  //     extras: ["0x079e7A44F42E9cd2442C3B9536244be634e8f888"],
  //   })
  // );
  // await awaitTx(
  //   pathFinder.addPair("0x471EcE3750Da237f93B8E339c536989b8978a438", {
  //     path: [
  //       "0x471EcE3750Da237f93B8E339c536989b8978a438",
  //       "0x765DE816845861e75A25fCA122bb6898B8B1282a",
  //     ],
  //     pairs: ["0x5ea0Edebe6a8e6ad1965BdB06A4630e8d3526360"],
  //     extras: ["0x079e7A44F42E9cd2442C3B9536244be634e8f888"],
  //   })
  // );

  // await awaitTx(
  //   graph.removePair("0x765DE816845861e75A25fCA122bb6898B8B1282a", )
  // );
  // const q = await graph.getTokenPairs(
  //   "0x765DE816845861e75A25fCA122bb6898B8B1282a"
  //   // "0xD8763CBa276a3738E6DE85b4b3bF5FDed6D6cA73"
  // );
  // console.log(q);
  // console.log(q.length)
}

async function swap() {
  const factory = await ethers.getContractFactory("PathFinder");
  const pathFinder = await factory.attach(PATH_FINDER);

  // const best = await pathFinder.getBestSwapPath(
  //   "0x765DE816845861e75A25fCA122bb6898B8B1282a",
  //   "0x471EcE3750Da237f93B8E339c536989b8978a438",
  //   "1" + "0".repeat(18),
  //   1
  // );
  // console.info(best.bestOutput.toString());
  // console.info(
  //   best.bestPath.map((path: any) => ({
  //     path: path.path,
  //     pairs: path.pairs,
  //     extras: path.extras,
  //   }))
  // );
}

export async function pathFinder() {
  await pairs();
  await swap();
}
