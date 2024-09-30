import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";

task("sculptures", "Set sculptures", sculptures);

export default async function sculptures(taskArgs: TaskArguments, hre: HardhatRuntimeEnvironment) {
  if (hre.network.name === "hardhat" || hre.network.name === "localhost") {
    const sculptures = [
      // Here be addresses
    ];
  } else if (hre.network.name === "sepolia") {
    console.log("Setting sculptures on Sepolia");
    const sculptures = [
      "0x6a7139325371a314Fe1374063869F89cB7c09D57"
    ];
    const Garden = await hre.deployments.get("Garden");
    const garden = await hre.ethers.getContractAt("Garden", Garden.address);
    await garden.setSculptures(sculptures);
  } else {
    throw new Error("Unsupported network");
  }
}
