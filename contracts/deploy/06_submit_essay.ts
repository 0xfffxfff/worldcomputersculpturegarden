import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import essayText from "../../ESSAY";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getUnnamedAccounts } = hre;
  const [deployer] = await getUnnamedAccounts();

  const essayDeployment = await deployments.get("Essay");
  const essay = await hre.ethers.getContractAt(
    "Essay",
    essayDeployment.address
  );

  const text = await essay.text();

  if (text == essayText.essay) {
    console.log(`Essay text already up to date!`);
    return;
  }

  console.log(`Setting essay text...`);
  await essay.setText(essayText.essay, {
    from: deployer
  });
  console.log(`Essay text set!`);
};

export default func;
func.tags = ["EssayText"];
