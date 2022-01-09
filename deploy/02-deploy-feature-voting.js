module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("FeatureVoting", {
    from: deployer,
    args: ["0x305dbFD4e55C35c16aFdC5D8c470DaB195FA54C7"],
    log: true,
  });
};
module.exports.tags = ["FeatureVoting"];
