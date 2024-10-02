import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";

task("get", "Get Sculpture data", get)
.addParam("address", "Sculpture address");

export default async function get(taskArgs: TaskArguments, hre: HardhatRuntimeEnvironment) {
  const address = taskArgs.address;
  const sculpture = await hre.ethers.getContractAt("Sculpture", address);

  const title = await sculpture.title();
  const authors = await sculpture.authors();
  const addresses = await sculpture.addresses();
  const text = await sculpture.text();
  const urls = await sculpture.urls();

  console.log("Title:", title);
  console.log("Authors:", authors);
  console.log("Addresses:", addresses);
  console.log("URLs:", urls);
  console.log("Text:", text.split('<br>'));
}
