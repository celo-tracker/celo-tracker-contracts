module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("GaslessSwap", {
    from: deployer,
    args: [
      "0xF35ed7156BABF2541E032B3bB8625210316e2832",
      "0x7a6daee82f0A5141fd9e5443caA5eaa39147415f",
    ],
    log: true,
  });
};
module.exports.tags = ["GaslessSwap"];
