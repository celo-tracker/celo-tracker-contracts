module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("OperatorProxy", {
    from: deployer,
    args: [
      "0x76cAD835648Edee3d460Ba8c48517f6924A6CF4B", // SushiOperator
      "0x3C655Fd232B11504C778021c304010f5aAF68958", // UbeOperator
    ],
    log: true,
  });
};
module.exports.tags = ["OperatorProxy"];
