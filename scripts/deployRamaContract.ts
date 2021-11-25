import { ethers } from "hardhat";

async function main() {
  // Person who deploys the contract
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts with ${deployer.address}`);

  // Person who deploys the contract has minter role
  const RamaToken = await ethers.getContractFactory("RamaToken");
  const ramaToken = await RamaToken.deploy();
  console.log(`RamaToken address: ${ramaToken.address}`);

  // Mints certain amount of Rama tokens to the RamaContract address
  const RamaContract = await ethers.getContractFactory("RamaContract");
  const ramaContract = await RamaContract.deploy(ramaToken.address);
  console.log(`RamaContract address: ${ramaContract.address}`);

  await ramaToken.connect(deployer).mint(ramaContract.address, 10000);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });
