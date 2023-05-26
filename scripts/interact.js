require("@nomiclabs/hardhat-ethers");
require("dotenv").config();
var fs = require('fs');
const util = require('util');
var ethers = require('ethers')
const fsPromises = fs.promises;
//The path to the contract ABI
const ABI_FILE_PATH = '';
//The address from the deployed smart contract
const DEPLOYED_CONTRACT_ADDRESS = '0x75436215885F5D19F4482681bfe1D85CBDE28a16';
//Load ABI from build artifacts
async function getAbi(){
    const data = await fsPromises.readFile(ABI_FILE_PATH, 'UTF8');
    const abi = JSON.parse(data);
    console.log(abi);
   // return abi;
}
async function main(){
    const {ALCHEMY_PROJECT_ID} = process.env;
    let provider = ethers.getDefaultProvider('https://rpc.ankr.com/polygon_mumbai/EYBTYC76SFHJRMQ1XWPRVPUCR4GI9JIYWK');
    const abi = await getAbi()
    console.log(abi);
    //Read-only operations require only a provider.
    //Providers allow only for read operations.
    const contract = new ethers.Contract(DEPLOYED_CONTRACT_ADDRESS, abi, provider);
    const owner = await contract.addAdmin();
    console.log(owner);
    //Write operations require a signer
    const {PRIVATE_KEY} = process.env;
    const signer = new ethers.Wallet(PRIVATE_KEY, provider);
    const new_contract = new ethers.Contract(contractAddress, abi, signer);
    let tx = await new_contract.setOwner('');
    await tx.wait();
    const updated_owner = await new_contract.addAdmin();
    console.log(updated_owner);
}
main()
.then(() => process.exit(0))
.catch((error) =>{
    console.error(error);
    process.exit(1);
});