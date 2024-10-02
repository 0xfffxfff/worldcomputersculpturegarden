import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

import SCULPTURES from "../../SCULPTURES.json";
import { ethers } from "hardhat";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getUnnamedAccounts } = hre;
  const { deploy } = deployments;
  const [deployer] = await getUnnamedAccounts();

  const gardenDeployment = await deployments.get("Garden");
  const garden = await hre.ethers.getContractAt(
    "Garden",
    gardenDeployment.address
  );

  const sculptureList = [];

  const chainId = await hre.getChainId();

  console.log(`Deploying sculptures for chain ${chainId}`);
  for (const artist of SCULPTURES.artists) {
    // @ts-ignore
    const address = SCULPTURES.sculptures?.[chainId]?.[artist];

    // EXCEPTION: FIGURE 31
    if (artist === "figure31") {
      console.log("Deploying Travel for figure31");
      const perlin = await deploy("Perlin", {
        from: deployer,
        log: true,
      });
      const travel = await deploy("Travel", {
        from: deployer,
        log: true,
        libraries: {
          Perlin: perlin.address,
        }
      });
      console.log(`Travel deployed at ${travel.address}`);
      sculptureList.push(travel.address);
      continue;
    }

    // EXCEPTION: RHEA MYERS
    if (artist === "rheamyers") {
      const showCritique = await deploy("ShowCritique", {
        from: deployer,
        log: true
      });
      const showCritiqueInstance = await hre.ethers.getContractAt("ShowCritique", showCritique.address);
      await showCritiqueInstance.configure(gardenDeployment.address);
      sculptureList.push(showCritique.address);
      continue;
    }

    // REGULAR
    if (address && ethers.isAddress(address)) {
      console.log(`Sculpture available for ${artist} at ${address}`);
      sculptureList.push(address);
    } else {
      console.log(`No sculpture available for ${artist}`);
      console.log(`Deploying placeholder`);
      const placeholder = await deploy(`Placeholder${artist}`, {
        from: deployer,
        log: true,
      });
      console.log(`Placeholder deployed at ${placeholder.address}`);
      sculptureList.push(placeholder.address);
    }
  }

  console.log("Setting sculptures on Garden: ", sculptureList.join(", "));
  await garden.setSculptures(sculptureList);
};

export default func;
func.tags = ["Placeholders"];
