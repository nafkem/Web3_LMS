//require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();
require("@nomiclabs/hardhat-waffle");
require('@nomiclabs/hardhat-ethers');
require('@nomiclabs/hardhat-etherscan');
const { POLYGON_MUMBAI_RPC_PROVIDER, PRIVATE_KEY, POLYGONSCAN_API_KEY } = process.env;
// Any file that has require('dotenv').config() statement 
// will automatically load any variables in the root's .env file.
module.exports = {
    solidity: {
      version: '0.8.17',
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        },
      },
    },
      networks: {
       mumbai: {
        url: `https://rpc.ankr.com/polygon_mumbai/`,
        accounts: [`0x${process.env.PRIVATE_KEY}`],
        etherscan: {
          apiKey: {
            polygonMumbai: '',
          },
        },
        gas: 2100000,
        gasPrice: 8000000000, // 8 gwei
      },
    },
    };