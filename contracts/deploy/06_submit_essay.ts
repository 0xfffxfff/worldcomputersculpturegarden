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
  } else {
    console.log(`Setting essay text...`);
    await essay.setText(essayText.essay, {
      from: deployer,
      gasLimit: 30_000_000,
      gasPrice: 5000000000,
    });
    console.log(`Essay text set!`);
  }

  const title = await essay.title();
  if (title == essayText.title) {
    console.log(`Essay title already up to date!`);
  } else {
    console.log(`Setting essay title...`);
    await essay.setTitle(essayText.title, {
      from: deployer,
      gasLimit: 30_000_000,
      gasPrice: 5000000000,
    });
    console.log(`Essay title set!`);
  }
};

export default func;
func.tags = ["EssayText"];
