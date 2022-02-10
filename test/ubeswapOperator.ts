import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import { BigNumber, Contract, ContractFactory } from 'ethers'
import { ethers } from 'hardhat'
import { setupMiniChef } from './sushiswap'
import { setupUniswapPools } from './uniswap'
import { awaitTx, wei } from './utils'

describe('Ubeswap Operator', function () {
  // `beforeEach` will run before each test, re-deploying the contract every
  // time. It receives a callback, which can be async.
  let token0: Contract
  let token1: Contract
  let router: Contract
  let factory: Contract
  let lpToken: string
  let _: SignerWithAddress
  let sushi: Contract

  let miniChef: Contract
  let account1: SignerWithAddress
  let operatorFactory: ContractFactory
  let operator: Contract
  let pairFactory: ContractFactory
  let lpTokenContract: Contract

  beforeEach(async function () {
    ;({ token0, token1, router, factory, lpToken } = await setupUniswapPools())
    ;({ sushi, miniChef } = await setupMiniChef(lpToken))

    ;[_, account1] = await ethers.getSigners()

    operatorFactory = await ethers.getContractFactory('Operator')
    operator = await operatorFactory.deploy(
      router.address,
      factory.address,
      miniChef.address,
    )
    await operator.deployed()

    pairFactory = await ethers.getContractFactory('UniswapV2Pair')
    lpTokenContract = await pairFactory.attach(lpToken)
  })

  it('zaps into ubeswap using one token', async function () {
    await awaitTx(token0.transfer(account1.address, wei(10)))
    await awaitTx(token0.connect(account1).approve(operator.address, wei(10)))
    await awaitTx(
      operator
        .connect(account1)
        .swapAndZapIntoUbeswap(
          token0.address,
          token1.address,
          wei(10),
          wei(99, 10),
          98,
        ),
    )

    // ASSERTIONS

    // Operator doesn't have any leftovers.
    expect(await token0.balanceOf(operator.address)).to.eq(0)
    expect(await token1.balanceOf(operator.address)).to.eq(0)
    expect(await lpTokenContract.balanceOf(operator.address)).to.eq(0)

    // Account 1 has a balance of lp token.
    const lpTokenbalance = await lpTokenContract.balanceOf(account1.address)
    expect(lpTokenbalance).to.gt(0)
  })

  it("zaps into ubeswap using two tokens", async function () {
      await awaitTx(token0.transfer(account1.address, wei(5)));
      await awaitTx(token1.transfer(account1.address, wei(10)));
      await awaitTx(token0.connect(account1).approve(operator.address, wei(5)));
      await awaitTx(token1.connect(account1).approve(operator.address, wei(10)));
      await awaitTx(
        operator
          .connect(account1)
          .zapIntoUbeswap(token0.address, token1.address, wei(5), wei(10), 98)
      );
  
      // ASSERTIONS
  
      const pairFactory = await ethers.getContractFactory("UniswapV2Pair");
      const lpTokenContract = await pairFactory.attach(lpToken);
  
      // Operator doesn't have any leftovers.
      expect(await token0.balanceOf(operator.address)).to.eq(0);
      expect(await token1.balanceOf(operator.address)).to.eq(0);
      expect(await lpTokenContract.balanceOf(operator.address)).to.eq(0);
    
      // Account 1 has a balance of lp token.
      const lpTokenBalance = await lpTokenContract.balanceOf(account1.address);
      expect(lpTokenBalance).to.gt(0);
    });
})
