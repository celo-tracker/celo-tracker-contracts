import { ethers } from "hardhat";

const UNI_V3_PAIR = "0x5ea0Edebe6a8e6ad1965BdB06A4630e8d3526360";

export async function uniV3Pair() {
  const factory = await ethers.getContractFactory("PairUniswapV3");
  const pair = await factory.attach(UNI_V3_PAIR);

  console.info(
    (
      await pair.callStatic.getOutputAmount(
        "0x765DE816845861e75A25fCA122bb6898B8B1282a",
        "0x471EcE3750Da237f93B8E339c536989b8978a438",
        "1" + "0".repeat(18),
        "0x079e7a44f42e9cd2442c3b9536244be634e8f888"
      )
    ).toString()
  );
}
