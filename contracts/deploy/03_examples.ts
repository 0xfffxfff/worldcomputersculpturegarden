import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getUnnamedAccounts } = hre;
  const { deploy } = deployments;
  const [deployer] = await getUnnamedAccounts();


  if (hre.network.name !== "localhost" && hre.network.name !== "hardhat") {
    console.log("Can only deploy examples locally. Skipping.");
    return;
  }

  const gardenDeployment = await deployments.get("Garden");
  const garden = await hre.ethers.getContractAt(
    "Garden",
    gardenDeployment.address
  );

  const example1 = await deploy("ExampleSculptureStatic", {
    from: deployer,
  });
  const example2 = await deploy("ExampleSculptureDynamic", {
    from: deployer,
  });
  const example3 = await deploy("ExampleRemoteWork", {
    args: [(await deploy("RemoteArtwork", { from: deployer })).address],
    from: deployer,
  });
  const example4 = await deploy("ExampleSculptureStaticLongUrl", {
    from: deployer,
  });
  const perlin = await deploy("Perlin", {
    from: deployer,
  });
  const travel = await deploy("Travel", {
    from: deployer,
    libraries: {
      Perlin: perlin.address,
    },
  });

  await garden.setSculptures([
    example1.address,
    example2.address,
    example3.address,
    example4.address,
    travel.address,
  ]);
};

export default func;
func.tags = ["Examples"];
