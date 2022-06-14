module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("SwapWithFee", {
    from: deployer,
    args: [
      "0xF35ed7156BABF2541E032B3bB8625210316e2832",
      "0xe0c8c2A53EebadcD6a3b2c7564E428BDF276909B",
      1500,
    ],
    log: true,
  });
};
module.exports.tags = ["SwapWithFee"];
