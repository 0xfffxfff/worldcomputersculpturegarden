import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-contract-sizer";
import "hardhat-deploy";

import "./tasks";

const config: HardhatUserConfig = {
  solidity: "0.8.27",
  contractSizer: {
    runOnCompile: process.env.REPORT_SIZE === "true",
  }
};

export default config;
