import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";

task("dev:contribspam", "Spam contributions", contribspam);

export default async function contribspam(taskArgs: TaskArguments, hre: HardhatRuntimeEnvironment) {
  if (hre.network.name !== "localhost" && hre.network.name !== "hardhat") {
    throw new Error("This task can only be run on localhost or hardhat network");
  }
  // Get hardhat signers
  const signers = await hre.ethers.getSigners();
  const Garden = await hre.deployments.get("Garden");
  const garden = await hre.ethers.getContractAt("Garden", Garden.address);

  for (let i = 0; i < 20; i++) {
    for (let j = 0; j < Math.ceil(Math.random()*10); j++) {
      const acc = signers[i];
      await acc.sendTransaction({
        to: await garden.getAddress(),
        value: hre.ethers.parseEther((Math.random()*1).toFixed(18)),
      });
    }
  }
}
