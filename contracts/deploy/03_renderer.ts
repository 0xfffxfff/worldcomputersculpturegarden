import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getUnnamedAccounts } = hre;
  const { deploy } = deployments;
  const [deployer] = await getUnnamedAccounts();

  const garden = await deployments.get("Garden");

  const renderer = await deploy("GardenRenderer", {
    args: [garden.address],
    from: deployer,
    log: true
  });

  const web = await deployments.get("Web");
  const webContract = await hre.ethers.getContractAt("Web", web.address);
  await webContract.setRenderer(renderer.address);

};

export default func;
func.tags = ["GardenRenderer"];