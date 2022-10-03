module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("UniV2Multicall", {
    from: deployer,
    args: [],
    log: true,
  });
};
module.exports.tags = ["UniV2Multicall"];
