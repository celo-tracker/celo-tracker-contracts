module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("SushiOperator", {
    from: deployer,
    args: [
      "0x1421bDe4B10e8dd459b3BCb598810B1337D56842", // router
      "0xc35DADB65012eC5796536bD9864eD8773aBc74C4", // factory
      "0x8084936982D089130e001b470eDf58faCA445008", // minichef
      "0x08A588dfaF7C2AA3a96bc16dd7df3704915b1E49", // rewarder
    ],
    log: true,
  });
};
module.exports.tags = ["SushiOperator"];
