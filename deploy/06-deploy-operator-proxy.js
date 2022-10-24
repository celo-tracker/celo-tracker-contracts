module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("OperatorProxy", {
    from: deployer,
    args: [
      // Celo
      //"0x76cAD835648Edee3d460Ba8c48517f6924A6CF4B", // SushiOperator
      //"0x3C655Fd232B11504C778021c304010f5aAF68958", // UbeOperator

      // Polygon
      "0xDDdF7fC64b1ABC55fdEC219D1b20411ce9776479", // SushiOperator
      "0x0D57f319f4539D51e2cE792D99f565828C2AD043" // UbeOperator
    ],
    log: true,
  });
};
module.exports.tags = ["OperatorProxy"];
