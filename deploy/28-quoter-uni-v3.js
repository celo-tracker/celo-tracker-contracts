module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("UniswapV3Quoter", {
    from: deployer,
    args: [],
    log: true,
  });
};
module.exports.tags = ["UniswapV3Quoter"];
