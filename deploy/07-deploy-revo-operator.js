module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("RevoOperator", {
    from: deployer,
    args: [
      "0xE3D8bd6Aed4F159bc8000a9cD47CffDb95F96121", // router
      "0x62d5b84bE28a183aBB507E125B384122D2C25fAE", // factory,
      "0x2e031Fd9930b6aa96e8aC7ad528459817c96Ed70", // farmBot,
      "0x08da61b51AAcEB6DCf147A3a682BA8121158366F", // rewarder
    ],
    log: true,
  });
};
module.exports.tags = ["RevoOperator"];
