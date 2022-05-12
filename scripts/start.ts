import { ethers } from "hardhat";
import { awaitTx } from "../test/utils";

async function main() {
  const Energy = await ethers.getContractFactory("Energy");
  const energy = await Energy.attach(
    "0x84c4e1f2965235f60073e3029788888252c4557e"
  );

  const minterRole = await energy.MINTER_ROLE();
  await awaitTx(
    energy.revokeRole(minterRole, "0xfCF7Ae61c0D4D205Be92c119359A5faD0dc0A70D")
  );
  await awaitTx(
    energy.grantRole(minterRole, "0xfE28A724F1FfF9Fe76196E2525Aa6357512963f0")
  );

  const spenderRole = await energy.SPENDER_ROLE();
  await awaitTx(
    energy.revokeRole(spenderRole, "0x8c5ef280f769Eb94d6c217A3c8524680d6bF6141")
  );
  await awaitTx(
    energy.grantRole(spenderRole, "0xF647cd04667320E653Ce8dF13010bD111F55fDb8")
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
