import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Address, DeployFunction } from "hardhat-deploy/types";

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

  const sculptureList: Address[] = [];

  const chainId = await hre.getChainId();

  console.log(`Deploying sculptures for chain ${chainId}`);
  for (const artist of SCULPTURES.artists) {
    // @ts-ignore
    const address = SCULPTURES.sculptures?.[chainId]?.[artist];

    if (address && ethers.isAddress(address)) {
      console.log(`Sculpture available for ${artist} at ${address}`);
      sculptureList.push(address);
    } else if (artist === "rheamyers") { // EXCEPTION: RHEA MYERS
      const ENSResolver = await deployments.get("ENSResolver");
      const showCritique = await deploy("ShowCritique", {
        from: deployer,
        log: true,
        libraries: {
          ENSResolver: ENSResolver.address,
        },
      });
      const showCritiqueInstance = await hre.ethers.getContractAt("ShowCritique", showCritique.address);
      await showCritiqueInstance.configure(gardenDeployment.address);
      sculptureList.push(showCritique.address);
      continue;
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

  const sculptures = await garden.getSculptures();
  if (sculptures.every((sculpture) => sculptureList.includes(sculpture))) {
    console.log("Sculptures already set on Garden");
  } else {
    console.log("Setting sculptures on Garden");
    await garden.setSculptures(sculptureList);
  }
};

export default func;
func.tags = ["Sculptures"];
