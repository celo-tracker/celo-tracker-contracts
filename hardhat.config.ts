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
    celo: {
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
      url: "https://rpc.ankr.com/polygon",
      chainId: 137,
      accounts: [privateKey],
    },
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
      chainId: 4,
      accounts: [privateKey],
    },
    avalanche: {
      url: "https://api.avax.network/ext/bc/C/rpc",
      chainId: 43114,
      accounts: [privateKey],
    },
    bsc: {
      url: "https://bsc-dataseed1.binance.org",
      chainId: 56,
      accounts: [privateKey],
    },
    ethereum: {
      url: "https://eth-mainnet.g.alchemy.com/v2/It_s0N2Ns0unCeTbDPPD054KzIkURJhz",
      chainId: 1,
      accounts: [privateKey],
      gasPrice: 5000000000, // 3 gwei
    },
    optimism: {
      url: "https://opt-mainnet.g.alchemy.com/v2/-WlyqPmXuAjDDBqsPrqbFa_ABibhsDb7",
      chainId: 10,
      accounts: [privateKey],
    },
    arbitrum: {
      url: "https://arb-mainnet.g.alchemy.com/v2/uZg9FYtBK56ESsNlBroKeqW1kBU9WfVB",
      chainId: 42161,
      accounts: [privateKey],
    },
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
