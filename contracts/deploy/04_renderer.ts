import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getUnnamedAccounts } = hre;
  const { deploy } = deployments;
  const [deployer] = await getUnnamedAccounts();

  const essay = await deployments.get("Essay");
  const garden = await deployments.get("Garden");

  const gardenHTML = await deploy("GardenHTML", {
    args: [],
    from: deployer,
    log: true
  });

  const gardenIndex = await deploy("GardenIndex", {
    args: [],
    from: deployer,
    log: true,
    libraries: {
      GardenHTML: gardenHTML.address
    }
  });

  const gardenEssay = await deploy("GardenEssay", {
    args: [],
    from: deployer,
    log: true,
    libraries: {
      GardenHTML: gardenHTML.address
    }
  });

  const renderer = await deploy("GardenRenderer", {
    args: [garden.address, essay.address],
    from: deployer,
    log: true,
    libraries: {
      GardenIndex: gardenIndex.address,
      GardenEssay: gardenEssay.address
    }
  });

  const web = await deployments.get("Web");
  const webContract = await hre.ethers.getContractAt("Web", web.address);
  console.log("Setting renderer on Web contract...");
  await webContract.setRenderer(renderer.address);
  console.log("Done!");
};

export default func;
func.tags = ["GardenRenderer"];