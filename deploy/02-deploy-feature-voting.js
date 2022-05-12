module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("FeatureVoting", {
    from: deployer,
    args: ["0x84c4e1f2965235f60073e3029788888252c4557e"],
    log: true,
  });
};
module.exports.tags = ["FeatureVoting"];
