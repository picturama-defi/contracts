import { ethers } from "hardhat";

const IntialSupply = "1000000000";

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

  await ramaToken.connect(deployer).mint(ramaContract.address, ethers.utils.parseEther(IntialSupply));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });
