import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getUnnamedAccounts } = hre;
  const { deploy } = deployments;
  const [deployer] = await getUnnamedAccounts();

  const example1 = await deploy("ExampleSculptureStatic", {
    from: deployer
  })
  const example2 = await deploy("ExampleSculptureDynamic", {
    from: deployer
  })
  const example3 = await deploy("ExampleRemoteWork", {
    args: [(await deploy("RemoteArtwork", { from: deployer })).address],
    from: deployer
  });
  const example4 = await deploy("ExampleSculptureStaticLongUrl", {
    from: deployer
  });

  await deploy("Garden", {
    args: [[
      example1.address,
      example2.address,
      example3.address,
      example4.address
    ]],
    from: deployer,
    gasLimit: 18_000_000,
    log: true,
  });
};

export default func;
func.tags = ["Garden"];