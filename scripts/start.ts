import { ethers } from "hardhat";

async function main() {
  const Greeter = await ethers.getContractFactory("Greeter");
  const greeter = await Greeter.attach(
    "0xEE0b72C0ac8ce837B2fF9905F265fDA4C8162ae3"
  );

  // await greeter.setGreeting("Testing stuff");
  console.log(await greeter.greet());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
