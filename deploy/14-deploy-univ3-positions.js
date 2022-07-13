module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("UniV3Positions", {
    from: deployer,
    args: [
      "0x3d79EdAaBC0EaB6F08ED885C05Fc0B014290D95A", // NFT position manager
      "0xafe208a311b21f13ef87e33a90049fc17a7acdec", // Factory
    ],
    log: true,
  });
};
module.exports.tags = ["UniV3Positions"];
