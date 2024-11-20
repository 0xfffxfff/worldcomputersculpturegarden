import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getUnnamedAccounts } = hre;
  const { deploy } = deployments;
  const [deployer] = await getUnnamedAccounts();


  const garden = await deployments.get("Garden");

  await deploy("ExternalWithdraw", {
    args: [garden.address],
    from: deployer,
    log: true
  });
  const ExternalWithdraw = await deployments.get("ExternalWithdraw");

  console.log("Deployed ExternalWithdraw to:", ExternalWithdraw.address);

  // const Garden = await deployments.get("Garden");
  // const garden = await hre.ethers.getContractAt(
  //   "Garden",
  //   Garden.address
  // );

  // console.log("Transferring ownership of Garden to ExternalWithdraw...");
  // await garden.transferOwnership(ExternalWithdraw.address);
  // console.log("Done!");
};

export default func;
func.tags = ["ExternalWithdraw"];
