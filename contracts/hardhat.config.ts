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
  verify: {
    etherscan: {
      apiKey: "WTVZMWIIUDFK44YBQ3KJS2DJ4QA87XC2GQ"
    },
  },
  gasReporter: {
    enabled: (process.env.REPORT_GAS) ? true : false
  },
  defaultNetwork: "localhost",
  networks: {
    hardhat: {
      // forking: {
        // url: 'https://mainnet.infura.io/v3/cd625a10fd7343a987a4463b1bc0873a',
      // }
    },
    sepolia: {
      url: "https://sepolia.infura.io/v3/cd625a10fd7343a987a4463b1bc0873a",
      chainId: 11155111,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
    mainnet: {
      url: 'https://mainnet.infura.io/v3/cd625a10fd7343a987a4463b1bc0873a',
      chainId: 1,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      live: true,
    }
  },
};

export default config;
