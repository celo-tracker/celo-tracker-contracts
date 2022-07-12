import { ContractTransaction } from "@ethersproject/contracts";
import { BigNumber } from "ethers";

export async function awaitTx(txPromise: Promise<ContractTransaction>) {
  const tx = await txPromise;
  return await tx.wait();
}

const decimals = BigNumber.from(10).pow(18);

// The divisor is to allow creating decimal numbers, since BigNumber doesn't support it.
// ie calling wei(25, 10) creates 2.5 wei.
export function wei(value: number, divisor: number = 1) {
  return BigNumber.from(value).mul(decimals).div(divisor);
}
