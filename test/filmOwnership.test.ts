import { ethers } from "hardhat";
import { expect } from "chai";

const bytes = (string) => ethers.utils.formatBytes32String(string)
const string = (bytes) => ethers.utils.parseBytes32String(bytes)

describe("Film ownership tests", function () {
    it("tests addition of films", async function () {
        const [, addr1] = await ethers.getSigners();

        const RamaTokenFactory = await ethers.getContractFactory("RamaToken");
        const ramaToken = await RamaTokenFactory.deploy();

        const RamaContractFactory = await ethers.getContractFactory("RamaContract");
        const ramaContract = await RamaContractFactory.deploy(ramaToken.address);

        await ramaContract.addProject(
            bytes("id1"),
            1000,
            addr1.address
        );

        await ramaContract.addProject(
            bytes("id2"),
            1000,
            addr1.address
        );

        const filmsAdded = await ramaContract.getAllProjectIds()

        expect(string(filmsAdded[0].toString())).to.eq("id1")
        expect(string(filmsAdded[1].toString())).to.eq("id2")
    });

    it("tests unauthorised users not allowed to add films", async function () {
        const [, addr1] = await ethers.getSigners();

        const RamaTokenFactory = await ethers.getContractFactory("RamaToken");
        const ramaToken = await RamaTokenFactory.deploy();

        const RamaContractFactory = await ethers.getContractFactory("RamaContract");
        const ramaContract = await RamaContractFactory.deploy(ramaToken.address);

        expect(ramaContract.connect(addr1).addProject(
            bytes("id1"),
            1000,
            addr1.address
        )).to.be.revertedWith('Ownable: caller is not the owner');
    });

    it("tests unauthorised users not allowed to add films", async function () {
        const [, addr1] = await ethers.getSigners();

        const RamaTokenFactory = await ethers.getContractFactory("RamaToken");
        const ramaToken = await RamaTokenFactory.deploy();

        const RamaContractFactory = await ethers.getContractFactory("RamaContract");
        const ramaContract = await RamaContractFactory.deploy(ramaToken.address);

        expect(ramaContract.connect(addr1).addProject(
            bytes("id1"),
            1000,
            addr1.address
        )).to.be.revertedWith('Ownable: caller is not the owner');
    });

    it("tests funding of films", async function () {
        const [deployer, addr1, addr2] = await ethers.getSigners();

        const RamaTokenFactory = await ethers.getContractFactory("RamaToken");
        const ramaToken = await RamaTokenFactory.deploy();

        const RamaContractFactory = await ethers.getContractFactory("RamaContract");
        const ramaContract = await RamaContractFactory.deploy(ramaToken.address);

        await ramaToken.connect(deployer).mint(ramaContract.address, 100000);

        await ramaContract.addProject(
            bytes("id1"),
            1000,
            addr1.address
        )

        await ramaContract.connect(addr1).fundProject(bytes("id1"), {
            value: 100
        })

        await ramaContract.connect(addr2).fundProject(bytes("id1"), {
            value: 200
        })

        const res = await ramaContract.getProjectById(bytes("id1"))

        const film = await ethers.getContractAt("Film", res);

        const funds = await film.getFunds()

        expect(funds[0]["funder"].toString()).to.eq("0x70997970C51812dc3A010C7d01b50e0d17dc79C8")
        expect(funds[1]["funder"].toString()).to.eq("0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC")

        expect(funds[0]["amount"].toString()).to.eq("100")
        expect(funds[1]["amount"].toString()).to.eq("200")
    });

    it("tests over funding of films", async function () {
        const [deployer, addr1, addr2] = await ethers.getSigners();

        const RamaTokenFactory = await ethers.getContractFactory("RamaToken");
        const ramaToken = await RamaTokenFactory.deploy();

        const RamaContractFactory = await ethers.getContractFactory("RamaContract");
        const ramaContract = await RamaContractFactory.deploy(ramaToken.address);

        await ramaToken.connect(deployer).mint(ramaContract.address, 100000);

        await ramaContract.addProject(
            bytes("id1"),
            1000,
            addr1.address
        )

        await ramaContract.connect(addr1).fundProject(bytes("id1"), {
            value: 100
        })

        expect(ramaContract.connect(addr2).fundProject(bytes("id1"), {
            value: 9001
        })).to.revertedWith("Excess fund")
    });

    it("calculates yield", async function () {
        const [deployer, addr1, addr2] = await ethers.getSigners();

        const RamaTokenFactory = await ethers.getContractFactory("RamaToken");
        const ramaToken = await RamaTokenFactory.deploy();

        const RamaContractFactory = await ethers.getContractFactory("RamaContract");
        const ramaContract = await RamaContractFactory.deploy(ramaToken.address);

        await ramaToken.connect(deployer).mint(ramaContract.address, 100000);

        await ramaContract.addProject(
            bytes("id1"),
            1000,
            addr1.address
        )

        await ramaContract.connect(addr1).fundProject(bytes("id1"), {
            value: 100
        })

        const res = await ramaContract.connect(addr1).getFundOfUserOnAProject(bytes("id1"));
    });
});
