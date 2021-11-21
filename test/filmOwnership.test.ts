import { ethers } from "hardhat";
import { expect } from "chai";

describe("Film ownership tests", function () {
  it("tests addition of films", async function () {
    const [, addr1] = await ethers.getSigners();

    const RamaTokenFactory = await ethers.getContractFactory("RamaToken");
    const ramaTokenContract = await RamaTokenFactory.deploy();

    await ramaTokenContract.addFilm(
      addr1.address,
      1000,
      ethers.utils.formatBytes32String("id1")
    );

    await ramaTokenContract.addFilm(
      addr1.address,
      2000,
      ethers.utils.formatBytes32String("id2")
    );

    const res = await ramaTokenContract.getAllProjects();

    expect(res[0]["targetAmount"].toString()).to.eq("1000");
    expect(res[0]["totalFunded"].toString()).to.eq("0");
    expect(ethers.utils.parseBytes32String(res[0]["id"])).to.eq("id1");

    expect(res[1]["targetAmount"].toString()).to.eq("2000");
    expect(res[1]["totalFunded"].toString()).to.eq("0");
    expect(ethers.utils.parseBytes32String(res[1]["id"])).to.eq("id2");
  });

  it("tests addition of a film by user who is not the admin", async function () {
    const [, addr1] = await ethers.getSigners();

    const RamaTokenFactory = await ethers.getContractFactory("RamaToken");
    const ramaTokenContract = await RamaTokenFactory.deploy();

    await expect(
      ramaTokenContract
        .connect(addr1)
        .addFilm(addr1.address, 1000, ethers.utils.formatBytes32String("id"))
    ).to.be.revertedWith("Unauthorised request");
  });

  it("tests funding of a film", async function () {
    const [owner, addr1] = await ethers.getSigners();

    const RamaTokenFactory = await ethers.getContractFactory("RamaToken");
    const ramaTokenContract = await RamaTokenFactory.deploy();

    ramaTokenContract
      .connect(owner)
      .addFilm(addr1.address, 1000, ethers.utils.formatBytes32String("id"));

    ramaTokenContract.fundFilm(ethers.utils.formatBytes32String("id"), {
      value: 100,
    });

    const res = await ramaTokenContract.getAllProjects();

    expect(res[0][1].toString()).to.eq("100");
  });

  it("tests over funding of a film", async function () {
    const [owner, addr1] = await ethers.getSigners();

    const RamaTokenFactory = await ethers.getContractFactory("RamaToken");
    const ramaTokenContract = await RamaTokenFactory.deploy();

    ramaTokenContract
      .connect(owner)
      .addFilm(addr1.address, 1000, ethers.utils.formatBytes32String("id1"));

    ramaTokenContract.fundFilm(ethers.utils.formatBytes32String("id1"), {
      value: 100,
    });

    await expect(
      ramaTokenContract
        .connect(addr1)
        .fundFilm(ethers.utils.formatBytes32String("id1"), {
          value: 1000,
        })
    ).to.be.revertedWith("Excess fund");
  });
});
