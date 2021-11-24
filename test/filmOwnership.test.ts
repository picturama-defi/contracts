// import { ethers } from "hardhat";
// import { expect } from "chai";

// const bytes = (string) => ethers.utils.formatBytes32String(string)
// const string = (bytes) => ethers.utils.parseBytes32String(bytes)

// describe("Film ownership tests", function () {
//   it("tests addition of films", async function () {
//     const [, addr1] = await ethers.getSigners();

//     const RamaTokenFactory = await ethers.getContractFactory("Films");
//     const ramaTokenContract = await RamaTokenFactory.deploy();

//     await ramaTokenContract.addFilm(
//       bytes("id1"),
//       1000,
//       addr1.address
//     );

//     await ramaTokenContract.addFilm(
//       bytes("id2"),
//       1000,
//       addr1.address
//     );

//     const filmsAdded = await ramaTokenContract.getAllFilmIds()

//     expect(string(filmsAdded[0].toString())).to.eq("id1")
//     expect(string(filmsAdded[1].toString())).to.eq("id2")
//   });

//   it("tests unauthorised users not allowed to add films", async function () {
//     const [, addr1] = await ethers.getSigners();

//     const RamaTokenFactory = await ethers.getContractFactory("RamaToken");
//     const ramaTokenContract = await RamaTokenFactory.deploy();

//     expect(ramaTokenContract.connect(addr1).addFilm(
//       bytes("id1"),
//       1000,
//       addr1.address
//     )).to.be.revertedWith('Ownable: caller is not the owner');
//   });

//   it("tests unauthorised users not allowed to add films", async function () {
//     const [, addr1] = await ethers.getSigners();

//     const RamaTokenFactory = await ethers.getContractFactory("RamaToken");
//     const ramaTokenContract = await RamaTokenFactory.deploy();

//     expect(ramaTokenContract.connect(addr1).addFilm(
//       bytes("id1"),
//       1000,
//       addr1.address
//     )).to.be.revertedWith('Ownable: caller is not the owner');
//   });

//   it("tests funding of films", async function () {
//     const [, addr1, addr2] = await ethers.getSigners();

//     const RamaTokenFactory = await ethers.getContractFactory("RamaToken");
//     const ramaTokenContract = await RamaTokenFactory.deploy();

//     await ramaTokenContract.addFilm(
//       bytes("id1"),
//       1000,
//       addr1.address
//     )

//     await ramaTokenContract.connect(addr1).fund(bytes("id1"), {
//       value: 100
//     })

//     await ramaTokenContract.connect(addr2).fund(bytes("id1"), {
//       value: 200
//     })

//     const res = await ramaTokenContract.getFilm(bytes("id1"))

//     const film = await ethers.getContractAt("Film", res);

//     const funds = await film.getFunds()

//     expect(funds[0].toString()).to.eq("100,0x70997970C51812dc3A010C7d01b50e0d17dc79C8,10,1")
//     expect(funds[1].toString()).to.eq("200,0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC,11,2")
//   });

//   it("tests over funding of films", async function () {
//     const [, addr1, addr2] = await ethers.getSigners();

//     const RamaTokenFactory = await ethers.getContractFactory("RamaToken");
//     const ramaTokenContract = await RamaTokenFactory.deploy();

//     await ramaTokenContract.addFilm(
//       bytes("id1"),
//       1000,
//       addr1.address
//     )

//     await ramaTokenContract.connect(addr1).fund(bytes("id1"), {
//       value: 100
//     })

//     expect(ramaTokenContract.connect(addr2).fund(bytes("id1"), {
//       value: 9001
//     })).to.revertedWith("Excess fund")
//   });

//   it("tests removal of funding", async function () {
//     const [, addr1, addr2] = await ethers.getSigners();

//     const RamaTokenFactory = await ethers.getContractFactory("RamaToken");
//     const ramaTokenContract = await RamaTokenFactory.deploy();

//     await ramaTokenContract.addFilm(
//       bytes("id1"),
//       1000,
//       addr1.address
//     )

//     await ramaTokenContract.connect(addr1).fund(bytes("id1"), {
//       value: 100
//     })

//     await ramaTokenContract.connect(addr2).fund(bytes("id1"), {
//       value: 200
//     })

//     await ramaTokenContract.connect(addr1).removeFund(bytes("id1"), 1)
//   });

//   it("tests removal of funding by user who is not the owner", async function () {
//     const [, addr1, addr2] = await ethers.getSigners();

//     const RamaTokenFactory = await ethers.getContractFactory("RamaToken");
//     const ramaTokenContract = await RamaTokenFactory.deploy();

//     await ramaTokenContract.addFilm(
//       bytes("id1"),
//       1000,
//       addr1.address
//     )

//     await ramaTokenContract.connect(addr1).fund(bytes("id1"), {
//       value: 100
//     })

//     await ramaTokenContract.connect(addr2).fund(bytes("id1"), {
//       value: 200
//     })

//     expect(ramaTokenContract.connect(addr2).removeFund(bytes("id1"), 1)).to.revertedWith("Invalid request");
//   });
// });
