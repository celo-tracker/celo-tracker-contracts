import { ContractTransaction } from "@ethersproject/contracts";
import { BigNumber } from "ethers";

export async function awaitTx(txPromise: Promise<ContractTransaction>) {
  const tx = await txPromise;
  await tx.wait();
}

const decimals = BigNumber.from(10).pow(18);

export function wei(value: number) {
  return BigNumber.from(value).mul(decimals);
}
