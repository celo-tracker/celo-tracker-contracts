module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("OperatorProxy", {
    from: deployer,
    args: [
      "0x82C8E6012208CDeDEFF769Ae5C063D5932DDd240",
      "0x60D1Fc74Ba80B8439EC565518676dc2E0623cD96",
    ],
    log: true,
  });
};
module.exports.tags = ["OperatorProxy"];
