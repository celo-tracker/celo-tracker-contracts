module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("PathFinder", {
    from: deployer,
    args: ["0xF35ed7156BABF2541E032B3bB8625210316e2832"],
    log: true,
  });
};
module.exports.tags = ["PathFinder"];
