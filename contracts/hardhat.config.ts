import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-contract-sizer";
import "hardhat-deploy";
import * as envEnc from "@chainlink/env-enc";
envEnc.config();

import "./tasks";

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  contractSizer: {
    runOnCompile: process.env.REPORT_SIZE === "true",
  },
  networks: {
    hardhat: {
      // forking: {
        // url: 'https://mainnet.infura.io/v3/cd625a10fd7343a987a4463b1bc0873a',
      // }
    },
    sepolia: {
      // url: "https://sepolia.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
      url: "https://1rpc.io/sepolia", // "https://ethereum-sepolia-rpc.publicnode.com",
      chainId: 11155111,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    }
  },
};

export default config;
