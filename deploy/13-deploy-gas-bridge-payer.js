module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("GasBridgePayer", {
    from: deployer,
    args: [
      // The first parameter is the Wormhole Core Bridge address in each network.
      // The second one the amount to send for gas.

      // Polygon
      // "0x7A4B5a56256163F07b2C80A7cA55aBE66c4ec4d7",
      // "100000000000000000", // 0.1

      // Celo
      "0xa321448d90d4e5b0A732867c18eA198e75CAC48E",
      "100000000000000000", // 0.1
    ],
    log: true,
  });
};
module.exports.tags = ["GasBridgePayer"];
