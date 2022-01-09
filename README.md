# Celo Tracker contracts

This project contains the contracts used on https://celotracker.com to vote on feature requests and maybe other things in the future.

Mainnet deployment:
- Energy: 0x305dbFD4e55C35c16aFdC5D8c470DaB195FA54C7
- Energy Rewarder: 0x117867E95f79430ee4AFb9aeF9Dae133Fa091971
- Feature Voting: 0x99e92CB3f7059874575DbbcDb1b74AD54d7ff98D

# This is a Hardhat project

Some tasks that can be run:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
npx hardhat help
REPORT_GAS=true npx hardhat test
npx hardhat coverage
npx hardhat run scripts/deploy.ts
TS_NODE_FILES=true npx ts-node scripts/deploy.ts
npx eslint '**/*.{js,ts}'
npx eslint '**/*.{js,ts}' --fix
npx prettier '**/*.{json,sol,md}' --check
npx prettier '**/*.{json,sol,md}' --write
npx solhint 'contracts/**/*.sol'
npx solhint 'contracts/**/*.sol' --fix
```

# Performance optimizations

For faster runs of your tests and scripts, consider skipping ts-node's type checking by setting the environment variable `TS_NODE_TRANSPILE_ONLY` to `1` in hardhat's environment. For more details see [the documentation](https://hardhat.org/guides/typescript.html#performance-optimizations).
