module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("UniV3Multicall", {
    from: deployer,
    args: [],
    log: true,
  });
};
module.exports.tags = ["UniV3Multicall"];
