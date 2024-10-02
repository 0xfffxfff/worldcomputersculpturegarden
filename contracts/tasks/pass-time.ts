import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";

task("passtime", "Pass 3 days of time", passTime);

export default async function passTime(taskArgs: TaskArguments, hre: HardhatRuntimeEnvironment) {
  if (hre.network.live) throw new Error("Cannot pass time on live network");
  await hre.ethers.provider.send("evm_increaseTime", [3 * 24 * 60 * 60]);

  // then advance a block
  for (let i = 0; i < 80; i++) {
    await hre.ethers.provider.send("evm_mine", []);
  }
}
