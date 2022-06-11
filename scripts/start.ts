/* eslint-disable no-unused-vars */

import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import { awaitTx } from "../test/utils";

async function grantRoles() {
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

async function markFeatureRequestAsFinished(featureIndex: number) {
  const FeatureVoting = await ethers.getContractFactory("FeatureVoting");
  const featureVoting = await FeatureVoting.attach(
    "0xF647cd04667320E653Ce8dF13010bD111F55fDb8"
  );

  await awaitTx(featureVoting.featureFinished(featureIndex));
}

async function fetchBalances() {
  const ERC20Balances = await ethers.getContractFactory("ERC20Balances");
  const erc20Balances = await ERC20Balances.attach(
    "0x9Fb1c7DE9A6FE1eE2fAdb22122931C1b9130111C"
  );

  console.log(
    (
      await erc20Balances.getBalances(
        "0xB8aDc11DCFD2ED55D1c41410BfdEFa3C57b56F86",
        [
          "0x471EcE3750Da237f93B8E339c536989b8978a438",
          "0x5fA00D2Ba520f95F548FF0813f9F74FACdF1b807",
        ]
      )
    ).map((balance: BigNumber) => balance.toString())
  );
}

async function main() {
  await fetchBalances();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
