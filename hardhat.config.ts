import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";
import "hardhat-deploy";

dotenv.config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// Defauly private key to be used on CI.
const privateKey =
  process.env.PRIVATE_KEY ??
  "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";

const config: HardhatUserConfig = {
  networks: {
    mainnet: {
      url: "https://forno.celo.org",
      chainId: 42220,
      accounts: [privateKey],
    },
    alfajores: {
      url: "https://alfajores-forno.celo-testnet.org",
      chainId: 44787,
      accounts: [privateKey],
    },
    polygon: {
      url: "https://polygon-rpc.com",
      chainId: 137,
      accounts: [privateKey],
    }
  },
  solidity: {
    version: "0.8.13",
    settings: {
      optimizer: {
        enabled: true,
        runs: 999999,
      },
      viaIR: true,
    },
  },
  gasReporter: {
    gasPrice: 1,
    enabled: false,
    showTimeSpent: true,
  },
  namedAccounts: {
    deployer: 0,
  },
};

export default config;
