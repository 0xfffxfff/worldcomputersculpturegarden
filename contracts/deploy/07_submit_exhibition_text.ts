import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import gardenText from "../../SHOWTEXT";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getUnnamedAccounts } = hre;
  const [deployer] = await getUnnamedAccounts();

  const modDeployment = await deployments.get("Mod");
  const mod = await hre.ethers.getContractAt(
    "Mod",
    modDeployment.address
  );

  const text = await mod.text();

  if (text == gardenText) {
    console.log(`Show text already up to date!`);
  } else {
    console.log(`Setting show text...`);
    await mod.setText(gardenText, {
      from: deployer,
      gasLimit: 30_000_000,
      gasPrice: 40_000_000_000,
    });
    console.log(`Show text set!`);
  }
};

export default func;
func.tags = ["ShowText"];
