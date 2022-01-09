import { ContractTransaction } from "@ethersproject/contracts";

export async function awaitTx(txPromise: Promise<ContractTransaction>) {
  const tx = await txPromise;
  await tx.wait();
}
