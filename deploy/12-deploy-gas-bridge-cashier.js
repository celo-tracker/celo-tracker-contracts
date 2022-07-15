module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("GasBridgeCashier", {
    from: deployer,
    args: [
      // The first parameter is the Wormhole Core Bridge address in each network
      // The second the treasury address

      "0x7A4B5a56256163F07b2C80A7cA55aBE66c4ec4d7", // Polygon
      "0x2f16d42AE636946eb98F0C7a20A82f8E3BB4B243",

      // "0xa321448d90d4e5b0A732867c18eA198e75CAC48E", // Celo
      // "0x60D3e18c57C9b1ec4e09F255aAB959F58FA1A724",
    ],
    log: true,
  });
};
module.exports.tags = ["GasBridgeCashier"];
