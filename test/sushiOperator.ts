import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { BigNumber, Contract, ContractFactory } from "ethers";
import { ethers } from "hardhat";
import { setupOperator } from "./operatorSetup";
import { setupMiniChef } from "./sushiswap";
import { setupUniswapPools } from "./uniswap";
import { awaitTx, wei } from "./utils";

describe("Sushi operator", function () {
  let token0: Contract;
  let token1: Contract;
  let router: Contract;
  let factory: Contract;
  let lpToken: string;
  let miniChef: Contract;
  let account1: SignerWithAddress;
  let operator: Contract;
  let pairFactory: ContractFactory;
  let lpTokenContract: Contract;

  beforeEach(async function () {
    ({ token0, token1, router, factory, lpToken } = await setupUniswapPools());
    ({ miniChef } = await setupMiniChef(lpToken));

    [, account1] = await ethers.getSigners();

    operator = await setupOperator(router, factory, miniChef);

    pairFactory = await ethers.getContractFactory("UniswapV2Pair");
    lpTokenContract = await pairFactory.attach(lpToken);
  });

  it("zaps into sushi using one token", async function () {
    await awaitTx(token0.transfer(account1.address, wei(10)));
    await awaitTx(token0.connect(account1).approve(operator.address, wei(10)));
    await awaitTx(
      operator
        .connect(account1)
        .swapAndZapInWithSushiwap(
          token0.address,
          token1.address,
          wei(10),
          wei(99, 10),
          98,
          0
        )
    );

    // ASSERTIONS

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

  it("zaps into sushi using two tokens", async function () {
    await awaitTx(token0.transfer(account1.address, wei(5)));
    await awaitTx(token1.transfer(account1.address, wei(10)));
    await awaitTx(token0.connect(account1).approve(operator.address, wei(5)));
    await awaitTx(token1.connect(account1).approve(operator.address, wei(10)));
    await awaitTx(
      operator
        .connect(account1)
        .zapInWithSushiswap(
          token0.address,
          token1.address,
          wei(5),
          wei(10),
          98,
          0
        )
    );

    // ASSERTIONS

    const pairFactory = await ethers.getContractFactory("UniswapV2Pair");
    const lpTokenContract = await pairFactory.attach(lpToken);

    // Operator doesn't have any leftovers.
    expect(await token0.balanceOf(operator.address)).to.eq(0);
    expect(await token1.balanceOf(operator.address)).to.eq(0);
    expect(await lpTokenContract.balanceOf(operator.address)).to.eq(0);

    // Account 1 has a balance in MiniChef.
    const { amount } = await miniChef.userInfo(0, account1.address);
    expect(amount).to.gt(0);

    // MiniChef has a balance of lp token.
    const miniChefBalance = await lpTokenContract.balanceOf(miniChef.address);
    expect(miniChefBalance).to.gt(0);

    const lpTokenTotalSupply = await lpTokenContract.totalSupply();
    const { _reserve0, _reserve1 } = await lpTokenContract.getReserves();
    const lpToken0 = await lpTokenContract.token0();
    const lpToken1 = await lpTokenContract.token1();
    const reserve0: BigNumber =
      lpToken0 === token0.address ? _reserve0 : _reserve1;
    const reserve1: BigNumber =
      lpToken1 === token1.address ? _reserve1 : _reserve0;
    const miniChefShare = miniChefBalance / lpTokenTotalSupply;

    // Note that passing the BigNumber to string and then to number with the +
    // is due to limitations on ethers BigNumber. A better way would be cool.
    const miniChefToken0Balance = +reserve0.toString() * miniChefShare;
    const miniChefToken1Balance = +reserve1.toString() * miniChefShare;

    expect(miniChefToken0Balance).to.gt(+wei(49, 10).toString());
    expect(miniChefToken1Balance).to.gt(+wei(99, 10).toString());
  });
});
