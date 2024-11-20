import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";

task("withdraw", "Withdraw the balance of the contract", get)
.addParam("to", "address to withdraw to");

export default async function get(taskArgs: TaskArguments, hre: HardhatRuntimeEnvironment) {
  const to = taskArgs.to;

  const externalWithdraw = await hre.deployments.get("ExternalWithdraw");
  const externalWithdrawContract = await hre.ethers.getContractAt("ExternalWithdraw", externalWithdraw.address);

  const garden = await hre.deployments.get("Garden");
  const gardenContract = await hre.ethers.getContractAt("Garden", garden.address);

  if (await gardenContract.owner() === externalWithdraw.address) {
    console.log(`Ownership of Garden already transferred to ExternalWithdraw`);
    console.log(`Withdrawing balance of Garden through ExternalWithdraw to ${to}...`);
    await externalWithdrawContract.withdraw(to);
    console.log(`Done!`);
  } else {
    console.log(`Ownership of Garden not transferred to ExternalWithdraw`);
    console.log(`Withdrawing directly from Garden to ${to}...`);
    await gardenContract.withdraw(to);
    console.log(`Done!`);
  }
}
