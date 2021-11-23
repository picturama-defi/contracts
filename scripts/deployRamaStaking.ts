import { ethers } from "hardhat";
import { mainConfig } from "./config";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts with ${deployer.address}`);

  const balance = await deployer.getBalance();
  console.log(`Account balance: ${balance.toString()}`);

  const RamaToken = await ethers.getContractFactory("RamaToken");
  const ramaToken = await RamaToken.deploy();
  console.log(`RamaToken address: ${ramaToken.address}`);

  const RamaStaking = await ethers.getContractFactory("RamaStaking");
  const ramaStaking = await RamaStaking.deploy(ramaToken.address);
  console.log(`RamaStaking address: ${ramaStaking.address}`);

  const ramaMinter = await ramaToken.MINTER_ROLE();
  await ramaToken.grantRole(ramaMinter, ramaStaking.address);
  console.log(`RamaToken minter role transferred to: ${ramaStaking.address}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });
