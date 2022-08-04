module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("SushiMulticall", {
    from: deployer,
    args: [],
    log: true,
  });
};
module.exports.tags = ["SushiMulticall"];
