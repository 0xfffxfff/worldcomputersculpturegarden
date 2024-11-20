import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";

task("transfer-garden-ownership-to-external-withdraw", "Withdraw the balance of the contract", transfer)

export default async function transfer(taskArgs: TaskArguments, hre: HardhatRuntimeEnvironment) {
  const garden = await hre.deployments.get("Garden");
  const gardenContract = await hre.ethers.getContractAt("Garden", garden.address);

  const externalWithdraw = await hre.deployments.get("ExternalWithdraw");
  const externalWithdrawContract = await hre.ethers.getContractAt("ExternalWithdraw", externalWithdraw.address);

  if (await gardenContract.owner() == externalWithdraw.address) { 
    console.log(`Ownership of Garden already transferred to ExternalWithdraw!`);
  } else {
    console.log(`Transferring ownership of Garden to ExternalWithdraw...`);
    await gardenContract.transferOwnership(externalWithdraw.address);
    console.log(`Ownership of Garden transferred to ExternalWithdraw!`);
  }
}
