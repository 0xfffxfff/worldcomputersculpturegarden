import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("Garden", function () {
  async function deployFixture() {
    const [owner, acc1] = await hre.ethers.getSigners();

    const StaticExample = await hre.ethers.getContractFactory(
      "ExampleSculptureStatic"
    );
    const example1 = await StaticExample.deploy();
    const DynamicExample = await hre.ethers.getContractFactory(
      "ExampleSculptureDynamic"
    );
    const example2 = await DynamicExample.deploy();
    const ExampleRemoteWork = await hre.ethers.getContractFactory("ExampleRemoteWork");
    const RemoteArtwork = await hre.ethers.getContractFactory("RemoteArtwork");
    const remoteArtwork = await RemoteArtwork.deploy();
    const example3 = await ExampleRemoteWork.deploy(await remoteArtwork.getAddress());
    const example4 = await(await hre.ethers.getContractFactory("ExampleSculptureStaticLongUrl")).deploy();

    const Web = await hre.ethers.getContractFactory("Web");
    const web = await Web.deploy();

    const Garden = await hre.ethers.getContractFactory("Garden");
    const garden = await Garden.deploy([
      await example1.getAddress(),
      await example2.getAddress(),
      await example3.getAddress(),
      await example4.getAddress(),
    ], await web.getAddress());

    const GardenRenderer = await hre.ethers.getContractFactory("GardenRenderer");
    const renderer = await GardenRenderer.deploy(await garden.getAddress());

    await (await web.setRenderer(await renderer.getAddress())).wait();

    return { garden, Garden, web, Web, owner, acc1 };
  }

  describe("Deployment", function () {
    it("Should deploy", async function () {
      const { garden } = await loadFixture(deployFixture);
      await expect(await garden.getAddress()).to.be.properAddress;
    });
  });

  describe("Web", function () {
    it("Should render html", async function () {
      const { web, owner } = await loadFixture(deployFixture);
      const html = await web.html();
      expect(html).to.contain("Example");
    });
  });
});
