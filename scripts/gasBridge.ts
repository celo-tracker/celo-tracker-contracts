/* eslint-disable no-unused-vars */

import { ethers } from "hardhat";
import { awaitTx, setAllowance, wei } from "../test/utils";

const CELO_CASHIER = "0x501B570e2BbC8b9656b747e273942472f699F6CF";
const CELO_PAYER = "0xF868B8a247434d758b5a828893DD39719931FD50";

const POLYGON_CASHIER = "0x4024929629182E2C115E2e6408d3eEE01AB97076";
const POLYGON_PAYER = "0x9FD0DB7b64b69D120E57BdC96e1547830F1aF813";

const cUSD = "0x765DE816845861e75A25fCA122bb6898B8B1282a";
const USDC_POLYGON = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174";

const POLYGON_CHAIN_ID = 5;
const CELO_CHAIN_ID = 14;

const MAX_NONCE_VALUE = 4294967296 - 1; // 2^32 - 1

async function celoCashierSetup() {
  const factory = await ethers.getContractFactory("GasBridgeCashier");
  const cashier = await factory.attach(CELO_CASHIER);

  await awaitTx(cashier.setGasTokenPrice(POLYGON_CHAIN_ID, cUSD, wei(1)));
}

async function polygonCashierSetup() {
  const factory = await ethers.getContractFactory("GasBridgeCashier");
  const cashier = await factory.attach(POLYGON_CASHIER);

  await awaitTx(
    cashier.setGasTokenPrice(CELO_CHAIN_ID, USDC_POLYGON, "1000000")
  );
}

async function celoPayerSetup() {
  const factory = await ethers.getContractFactory("GasBridgePayer");
  const payer = await factory.attach(CELO_PAYER);

  await awaitTx(
    payer.setChainIdCashier(POLYGON_CHAIN_ID, addressToBytes32(POLYGON_CASHIER))
  );
}

async function polygonPayerSetup() {
  const factory = await ethers.getContractFactory("GasBridgePayer");
  const payer = await factory.attach(POLYGON_PAYER);

  await awaitTx(
    payer.setChainIdCashier(CELO_CHAIN_ID, addressToBytes32(CELO_CASHIER))
  );
}

async function recoverFromPayer() {
  const factory = await ethers.getContractFactory("GasBridgePayer");
  const payer = await factory.attach(CELO_PAYER);

  await awaitTx(
    payer.recoverFunds(
      "0xf44e0c4e32f83a4b862d31e221dd462dcccbb6b4",
      "0x471EcE3750Da237f93B8E339c536989b8978a438"
    )
  );
}

async function sendGas(
  cashierAddress: string,
  targetChainId: number,
  paymentToken: string
) {
  const factory = await ethers.getContractFactory("GasBridgeCashier");
  const cashier = await factory.attach(cashierAddress);

  const paddedRecipient = addressToBytes32(
    "0x43d1eb966d0ADfe9E5C0d3Cff1223bed0823225C"
  );

  await setAllowance(paymentToken, cashierAddress, wei(1000));

  await awaitTx(
    cashier.sendGas(
      paddedRecipient,
      targetChainId,
      paymentToken,
      Math.floor(Math.random() * MAX_NONCE_VALUE)
    )
  );
}

async function main() {
  //   await celoPayerSetup();
  //   await polygonPayerSetup();
  //   await polygonCashierSetup();
  //   await sendGas(POLYGON_CASHIER, CELO_CHAIN_ID, USDC_POLYGON);
  //   await sendGas(CELO_CASHIER, POLYGON_CHAIN_ID, cUSD);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

function addressToBytes32(address: string): string {
  return "0x" + "00".repeat(12) + address.slice(2);
}
