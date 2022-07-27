module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("UbeswapOperator", {
    from: deployer,
    args: [
      // Celo - Ubeswap
      // "0xE3D8bd6Aed4F159bc8000a9cD47CffDb95F96121", // router
      // "0x62d5b84bE28a183aBB507E125B384122D2C25fAE", // factory
      // "0x08da61b51AAcEB6DCf147A3a682BA8121158366F", // rewarder

      // Polygon - Quickswap
      "0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff", // router
      "0x5757371414417b8c6caad45baef941abc7d3ab32", // factory
      "0xDbb5fE606db4240ce75D280c18d74536369543DB", // rewarder
    ],
    log: true,
  });
};

module.exports.tags = ["UbeswapOperator"];
