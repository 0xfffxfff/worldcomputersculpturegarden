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

  if (text == essayText.textPt1 + essayText.textPt2) {
    console.log(`Essay text already up to date!`);
  } else {
    console.log(`Setting essay text...`);
    const tx1 = await essay.setTextPt1(essayText.textPt1, {
      from: deployer,
      gasLimit: 30_000_000,
    });
    const tx2 = await essay.setTextPt2(essayText.textPt2, {
      from: deployer,
      gasLimit: 30_000_000,
    });
    console.log(`Essay text set!`, tx1.hash, tx2.hash);
  }

  const title = await essay.title();
  if (title == essayText.title) {
    console.log(`Essay title already up to date!`);
  } else {
    console.log(`Setting essay title...`);
    const tx = await essay.setTitle(essayText.title, {
      from: deployer,
      gasLimit: 30_000_000,
    });
    console.log(`Essay title set!`, tx.hash);
  }
};

export default func;
func.tags = ["EssayText"];
