import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import gardenText from "../../SHOWTEXT";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getUnnamedAccounts } = hre;
  const [deployer] = await getUnnamedAccounts();

  const gardenDeployment = await deployments.get("Garden");
  const garden = await hre.ethers.getContractAt(
    "Garden",
    gardenDeployment.address
  );

  const text = await garden.text();

  if (text == gardenText) {
    console.log(`Show text already up to date!`);
  } else {
    console.log(`Setting show text...`);
    await garden.setText(gardenText, {
      from: deployer,
      gasLimit: 30_000_000,
    });
    console.log(`Show text set!`);
  }
};

export default func;
func.tags = ["ShowText"];
