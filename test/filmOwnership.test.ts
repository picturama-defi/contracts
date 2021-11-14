import { ethers } from "hardhat";
import { expect } from "chai";

describe("Film ownership tests", function () {
  it("tests addition of films", async function () {
    const [, addr1] = await ethers.getSigners();

    const RamaTokenFactory = await ethers.getContractFactory("RamaToken");
    const ramaTokenContract = await RamaTokenFactory.deploy();

    await ramaTokenContract.addFilm(addr1.address, 1000);
    await ramaTokenContract.addFilm(addr1.address, 2000);

    const res = await ramaTokenContract.getAllProjects();

    expect(res[0].toString()).to.eq("1000,0,1");
    expect(res[1].toString()).to.eq("2000,0,2");
  });

  it("tests addition of a film by user who is not the admin", async function () {
    const [, addr1] = await ethers.getSigners();

    const RamaTokenFactory = await ethers.getContractFactory("RamaToken");
    const ramaTokenContract = await RamaTokenFactory.deploy();

    await expect(
      ramaTokenContract.connect(addr1).addFilm(addr1.address, 1000)
    ).to.be.revertedWith("Unauthorised request");
  });

  it("tests funding of a film", async function () {
    const [owner, addr1] = await ethers.getSigners();

    const RamaTokenFactory = await ethers.getContractFactory("RamaToken");
    const ramaTokenContract = await RamaTokenFactory.deploy();

    ramaTokenContract.connect(owner).addFilm(addr1.address, 1000);

    ramaTokenContract.fundFilm(1, {
      value: 100,
    });

    const res = await ramaTokenContract.getAllProjects();

    expect(res[0].toString()).to.eq("1000,100,1");
  });

  it("tests over funding of a film", async function () {
    const [owner, addr1] = await ethers.getSigners();

    const RamaTokenFactory = await ethers.getContractFactory("RamaToken");
    const ramaTokenContract = await RamaTokenFactory.deploy();

    ramaTokenContract.connect(owner).addFilm(addr1.address, 1000);

    ramaTokenContract.fundFilm(1, {
      value: 100,
    });

    await expect(
      ramaTokenContract.connect(addr1).fundFilm(1, {
        value: 1000,
      })
    ).to.be.revertedWith("Excess fund");
  });
});
