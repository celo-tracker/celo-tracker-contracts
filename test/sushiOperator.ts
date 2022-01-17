import { expect } from "chai";
import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import { setupMiniChef } from "./sushiswap";
import { setupUniswapPools } from "./uniswap";
import { awaitTx, wei } from "./utils";

describe("SushiSwap Operator", function () {
  it("Should behave as expected", async function () {
    const { token0, token1, router, factory, lpToken } =
      await setupUniswapPools();
    const { sushi, miniChef } = await setupMiniChef(lpToken);

    const [_, account1] = await ethers.getSigners();
    await awaitTx(token0.transfer(account1.address, wei(10)));

    const operatorFactory = await ethers.getContractFactory("SushiOperator");
    const operator = await operatorFactory.deploy(
      router.address,
      factory.address,
      miniChef.address
    );
    await operator.deployed();

    await awaitTx(token0.connect(account1).approve(operator.address, wei(10)));
    await awaitTx(
      operator
        .connect(account1)
        .zapIntoSushi(token0.address, token1.address, wei(10), wei(0), 90, 0)
    );

    // ASSERTIONS

    const pairFactory = await ethers.getContractFactory("UniswapV2Pair");
    const lpTokenContract = await pairFactory.attach(lpToken);

    // Operator doesn't have any leftovers.
    expect(await token0.balanceOf(operator.address)).to.eq(0);
    expect(await token1.balanceOf(operator.address)).to.eq(0);
    expect(await lpTokenContract.balanceOf(operator.address)).to.eq(0);

    expect(await lpTokenContract.balanceOf(operator.address)).to.eq(0);

    // Account 1 has a balance in MiniChef.
    const { amount } = await miniChef.userInfo(0, account1.address);
    expect(amount).to.gt(0);

    // MiniChef has a balance of lp token.
    const miniChefBalance = await lpTokenContract.balanceOf(miniChef.address);
    expect(miniChefBalance).to.gt(0);

    // The balance of token0 and token1 of miniChef is ~5 token0 and ~10 token1.
    const lpTokenTotalSupply = await lpTokenContract.totalSupply();
    const { _reserve0, _reserve1 } = await lpTokenContract.getReserves();
    const lpToken0 = await lpTokenContract.token0();
    const lpToken1 = await lpTokenContract.token1();
    const reserve0: BigNumber =
      lpToken0 === token0.address ? _reserve0 : _reserve1;
    const reserve1: BigNumber =
      lpToken1 === token0.address ? _reserve0 : _reserve1;
    const miniChefShare = miniChefBalance / lpTokenTotalSupply;
    // Note that passing the BigNumber to string and then to number with the +
    // is due to limitations on ethers BigNumber. A better way would be cool.
    const miniChefToken0Balance = +reserve0.toString() * miniChefShare;
    const miniChefToken1Balance = +reserve1.toString() * miniChefShare;
    // Zapped in with 10, sold half, ~5 was put in of token0.
    expect(miniChefToken0Balance).to.gt(+wei(49, 10).toString());
    expect(miniChefToken1Balance).to.gt(+wei(99, 10).toString());
  });
});
