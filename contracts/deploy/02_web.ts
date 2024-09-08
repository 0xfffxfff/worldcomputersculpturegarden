import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getUnnamedAccounts } = hre;
  const { deploy } = deployments;
  const [deployer] = await getUnnamedAccounts();

  const garden = await deployments.get("Garden");

  await deploy("Web", {
    args: [garden.address],
    from: deployer,
    log: true
  });

};

export default func;
func.tags = ["Web"];