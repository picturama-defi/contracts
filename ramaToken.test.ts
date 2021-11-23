import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("RamaToken Contract", () => {
  let owner: SignerWithAddress;
  let jithin: SignerWithAddress;
  let hoyt: SignerWithAddress;

  let ramaToken: Contract;
  let differentContract: Contract;

  before(async () => {
    const RamaToken = await ethers.getContractFactory("RamaToken");
    const DifferentContract = await ethers.getContractFactory("RamaToken");

    [owner, jithin, hoyt] = await ethers.getSigners();

    ramaToken = await RamaToken.deploy();
    differentContract = await DifferentContract.deploy();
  });

  describe("Init", async () => {
    it("should deploy", async () => {
      expect(ramaToken).to.be.ok;
    });

    it("has a name", async () => {
      expect(await ramaToken.name()).to.eq("RamaToken");
    });

    it("should have no supply after deployment", async () => {
      expect(await ramaToken.totalSupply()).to.eq(0);
    });
  });

  describe("Test minter role", async () => {
    it("should confirm deployer as owner", async () => {
      let minter = await ramaToken.MINTER_ROLE();
      await ramaToken.grantRole(minter, owner.address);
      expect(await ramaToken.hasRole(minter, owner.address)).to.eq(true);
    });

    it("should mint tokens from owner", async () => {
      expect(await ramaToken.balanceOf(owner.address)).to.eq(0);

      await ramaToken.mint(owner.address, 100);

      expect(await ramaToken.totalSupply()).to.eq(100);

      expect(await ramaToken.balanceOf(owner.address)).to.eq(100);
    });

    it("should revert mint from non-minter", async () => {
      await expect(ramaToken.connect(jithin).mint(jithin.address, 50)).to.be
        .reverted;
    });

    it("should revert transfer from non-admin", async () => {
      let minter = await ramaToken.MINTER_ROLE();
      await expect(ramaToken.connect(jithin).grantRole(minter, jithin.address))
        .to.be.reverted;
    });
  });
});
