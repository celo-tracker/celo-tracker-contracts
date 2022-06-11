module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("ERC20Balances", {
    from: deployer,
    args: [],
    log: true,
  });
};
module.exports.tags = ["ERC20Balances"];
