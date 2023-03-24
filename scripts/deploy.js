
const hre = require("hardhat");
async function main() {
    
const Web3Edu= await hre.ethers.getContractFactory("Web3Edu");
const web3Edu= await Web3Edu.deploy();
      await web3Edu.deployed();

  console.log(
    `Web3Edu deployed to ${web3Edu.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
