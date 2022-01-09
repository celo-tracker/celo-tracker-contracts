import { ethers } from "hardhat";
import { awaitTx } from "../test/utils";

async function main() {
  const Energy = await ethers.getContractFactory("Energy");
  const energy = await Energy.attach(
    "0x305dbFD4e55C35c16aFdC5D8c470DaB195FA54C7"
  );

  const minterRole = await energy.MINTER_ROLE();
  await awaitTx(
    energy.grantRole(minterRole, "0x117867E95f79430ee4AFb9aeF9Dae133Fa091971")
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
