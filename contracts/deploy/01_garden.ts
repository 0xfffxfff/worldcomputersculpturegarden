import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getUnnamedAccounts } = hre;
  const { deploy } = deployments;
  const [deployer] = await getUnnamedAccounts();

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

  const showCritique = await deploy("ShowCritique", {
    from: deployer
  });

  const web = await deployments.get("Web");

  const garden = await deploy("Garden", {
    args: [
      [
        example1.address,
        example2.address,
        example3.address,
        example4.address,
        showCritique.address
      ],
      web.address,
    ],
    from: deployer,
    gasLimit: 18_000_000,
    log: true,
  });

  const showCritiqueInstance = await hre.ethers.getContractAt(
  "ShowCritique",
  showCritique.address
  );
  //IMPORTANT: This *must* be called by the deploying/owning account
  // after the garden has been deployed.
  await showCritiqueInstance.configure(garden.address);
};

export default func;
func.tags = ["Garden"];
