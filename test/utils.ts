import { ContractTransaction } from "@ethersproject/contracts";
import { BigNumber } from "ethers";
import { ethers } from "hardhat";

export async function awaitTx(txPromise: Promise<ContractTransaction>) {
  const tx = await txPromise;
  await tx.wait();
}

const decimals = BigNumber.from(10).pow(18);

// The divisor is to allow creating decimal numbers, since BigNumber doesn't support it.
// ie calling wei(25, 10) creates 2.5 wei.
export function wei(value: number, divisor: number = 1) {
  return BigNumber.from(value).mul(decimals).div(divisor);
}

export async function setAllowance(
  tokenAddress: string,
  spender: string,
  allowance: BigNumber
) {
  const factory = await ethers.getContractFactory("ERC20");
  const token = await factory.attach(tokenAddress);

  await awaitTx(token.approve(spender, allowance));
}
