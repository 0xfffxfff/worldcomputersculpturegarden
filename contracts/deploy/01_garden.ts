import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getUnnamedAccounts } = hre;
  const { deploy } = deployments;
  const [deployer] = await getUnnamedAccounts();

  const web = await deployments.get("Web");

  await deploy("Garden", {
    args: [
      [],
      web.address,
      web.address, // TODO:
    ],
    from: deployer,
    gasLimit: 18_000_000,
    log: true,
  });
};

export default func;
func.tags = ["Garden"];
