import { ethers } from "hardhat";
import { expect } from "chai";

const bytes = (string) => ethers.utils.formatBytes32String(string)
const string = (bytes) => ethers.utils.parseBytes32String(bytes)

const initialSupply = 10000;

describe("Rama Token Logic", function () {
    // it("tests funding of a film", async function () {
    //     const [admin, addr1] = await ethers.getSigners();

    //     const RamaTokenFactory = await ethers.getContractFactory("RamaToken");
    //     const ramaTokenContract = await RamaTokenFactory.deploy(initialSupply);

    //     await ramaTokenContract.addProject(
    //         bytes("id1"),
    //         1000,
    //         addr1.address
    //     );
    // })
});
