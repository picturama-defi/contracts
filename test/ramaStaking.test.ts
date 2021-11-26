// import { ethers } from "hardhat";
// import chai, { expect } from "chai";
// import { solidity } from "ethereum-waffle";
// import { Contract, BigNumber } from "ethers";
// import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

// chai.use(solidity);

// describe("RamaStaking Contract", () => {
//   let res: any;

//   let owner: SignerWithAddress;
//   let jithin: SignerWithAddress;
//   let sylvester: SignerWithAddress;
//   let sanjay: SignerWithAddress;
//   let hoyt: SignerWithAddress;
//   let nemohoes: SignerWithAddress;

//   let ramaStaking: Contract;
//   let mockMatic: Contract;
//   let ramaToken: Contract;

//   const maticAmount: BigNumber = ethers.utils.parseEther("25000");

//   before(async () => {
//     const RamaStaking = await ethers.getContractFactory("RamaStaking");
//     const MockERC20 = await ethers.getContractFactory("MockERC20");
//     const RamaToken = await ethers.getContractFactory("RamaToken");
//     [owner, jithin, sylvester, sanjay, hoyt, nemohoes] =
//       await ethers.getSigners();

//     mockMatic = await MockERC20.deploy("MockMatic", "mMatic");
//     ramaToken = await RamaToken.deploy();

//     await Promise.all([
//       mockMatic.mint(owner.address, maticAmount),
//       mockMatic.mint(jithin.address, maticAmount),
//       mockMatic.mint(sylvester.address, maticAmount),
//       mockMatic.mint(sanjay.address, maticAmount),
//       mockMatic.mint(hoyt.address, maticAmount),
//       mockMatic.mint(nemohoes.address, maticAmount),
//     ]);

//     let ramaStakingParams: Array<string | BigNumber> = [ramaToken.address];
//     ramaStaking = await RamaStaking.deploy(...ramaStakingParams);
//   });

//   describe("Init", async () => {
//     it("should deploy contracts", async () => {
//       expect(ramaStaking).to.be.ok;
//       expect(ramaToken).to.be.ok;
//       expect(mockMatic).to.be.ok;
//     });

//     it("should return name", async () => {
//       expect(await ramaStaking.name()).to.eq("Rama Staking");
//       expect(await mockMatic.name()).to.eq("MockMatic");
//       expect(await ramaToken.name()).to.eq("RamaToken");
//     });

//     it("should show mockDai balance", async () => {
//       expect(await mockMatic.balanceOf(owner.address)).to.eq(maticAmount);
//     });
//   });

//   describe("Staking", async () => {
//     it("should stake and update mapping", async () => {
//       let toTransfer = ethers.utils.parseEther("100");
//       await mockMatic.connect(jithin).approve(ramaStaking.address, toTransfer);

//       expect(await ramaStaking.isStaking(jithin.address)).to.eq(false);

//       expect(await ramaStaking.connect(jithin).stakeTokens(toTransfer)).to.be
//         .ok;

//       expect(await ramaStaking.stakingBalance(jithin.address)).to.eq(
//         toTransfer
//       );

//       expect(await ramaStaking.isStaking(jithin.address)).to.eq(true);
//     });

//     it("should remove matic from user", async () => {
//       res = await mockMatic.balanceOf(jithin.address);
//       expect(Number(res)).to.be.lessThan(Number(maticAmount));
//     });

//     it("should update balance with multiple stakes", async () => {
//       let toTransfer = ethers.utils.parseEther("100");
//       await mockMatic
//         .connect(nemohoes)
//         .approve(ramaStaking.address, toTransfer);
//       await ramaStaking.connect(nemohoes).stakeTokens(toTransfer);
//     });

//     it("should revert stake with zero as staked amount", async () => {
//       await expect(
//         ramaStaking.connect(sylvester).stakeTokens(0)
//       ).to.be.revertedWith("You cannot stake zero tokens");
//     });

//     it("should revert stake without allowance", async () => {
//       let toTransfer = ethers.utils.parseEther("50");
//       await expect(
//         ramaStaking.connect(sylvester).stakeTokens(toTransfer)
//       ).to.be.revertedWith("transfer amount exceeds allowance");
//     });

//     it("should revert with not enough funds", async () => {
//       let toTransfer = ethers.utils.parseEther("1000000");
//       await mockMatic.approve(ramaStaking.address, toTransfer);

//       await expect(
//         ramaStaking.connect(sylvester).stakeTokens(toTransfer)
//       ).to.be.revertedWith("You cannot stake zero tokens");
//     });
//   });
//   // describe("Unstaking", async () => {
//   //   it("should unstake balance from user", async () => {
//   //     res = await ramaStaking.stakingBalance(jithin.address);
//   //     expect(Number(res)).to.be.greaterThan(0);

//   //     let toTransfer = ethers.utils.parseEther("100");
//   //     await ramaStaking.connect(jithin).unstake(toTransfer);
//   //     res = await ramaStaking.stakingBalance(jithin.address);
//   //     expect(Number(res)).to.eq(0);
//   //   });

//   //   it("should remove staking status", async () => {
//   //     expect(await ramaStaking.isStaking(jithin.address)).to.eq(false);
//   //   });

//   //   it("should transfer ownership", async () => {
//   //     let minter = await ramaToken.MINTER_ROLE();
//   //     await ramaToken.grantRole(minter, ramaStaking.address);

//   //     expect(await ramaToken.hasRole(minter, ramaStaking.address)).to.eq(true);
//   //   });
//   // });
// });
