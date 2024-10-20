import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";

task("withdraw", "Withdraw the balance of the contract", get)
.addParam("to", "address to withdraw to");

export default async function get(taskArgs: TaskArguments, hre: HardhatRuntimeEnvironment) {
  const to = taskArgs.to;

  const garden = await hre.deployments.get("Garden");
  const gardenContract = await hre.ethers.getContractAt("Garden", garden.address);
  console.log(`Withdrawing ${to}`);
  await gardenContract.withdraw(to);
  console.log(`Withdrawn ${to}`);
}
