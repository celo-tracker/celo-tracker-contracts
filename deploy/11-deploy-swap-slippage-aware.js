module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("SwapSlippageAwareWithFee", {
    from: deployer,
    args: [
      "0xF35ed7156BABF2541E032B3bB8625210316e2832", // Swapap router
      "0xe0c8c2A53EebadcD6a3b2c7564E428BDF276909B", // Beneficairy
      0,
    ],
    log: true,
  });
};
module.exports.tags = ["SwapSlippageAwareWithFee"];
