import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";
import "@nomicfoundation/hardhat-verify";
require("dotenv").config();

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    "base-mainnet": {
      url: "https://mainnet.base.org",
      accounts: [process.env.DEPLOYER as string],
      gasPrice: 1000000000,
    },
    "base-sepolia": {
      url: "https://sepolia.base.org",
      accounts: [process.env.DEPLOYER as string],
    },
  },
  etherscan: {
    apiKey: {
      baseSepolia: "DUMMY_KEY",
    },
  },
};

export default config;
