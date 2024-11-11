import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";

task("critique", "Critique a random piece randomly", critique);
export default async function critique(taskArgs: TaskArguments, hre: HardhatRuntimeEnvironment) {
  const critiqueDeployment = await hre.deployments.get("ShowCritique");
  const critique = await hre.ethers.getContractAt("ShowCritique", critiqueDeployment.address);

  const gardenDeployment = await hre.deployments.get("Garden");
  const garden = await hre.ethers.getContractAt("Garden", gardenDeployment.address);

  const sculptures = await garden.getSculptures();

  console.log("Critiquing", sculptures.length, "sculptures");

  for (let i = 0; i < sculptures.length; i++) {
    const crit = Math.floor(Math.random() * 16);
    console.log("Critiquing", i, sculptures[i], "with", crit);
    const tx = await critique.critiqueWork(i, sculptures[i], crit);
    console.log("Critiqued", i, sculptures[i], "with", crit, "tx", tx.data);
  }

  console.log("Done critiquing");
}
