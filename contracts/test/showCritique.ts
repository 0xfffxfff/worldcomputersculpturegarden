import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("Show Critique", function () {
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

    const ShowCritique = await hre.ethers.getContractFactory("ShowCritique");
    const showCritique = await ShowCritique.deploy();

    const Web = await hre.ethers.getContractFactory("Web");
    const web = await Web.deploy();

    const Garden = await hre.ethers.getContractFactory("Garden");
    const garden = await Garden.deploy([
      await example1.getAddress(),
      await example2.getAddress(),
      await example3.getAddress(),
      await example4.getAddress(),
      await showCritique.getAddress()
    ], await web.getAddress());

    const GardenRenderer = await hre.ethers.getContractFactory("GardenRenderer");
    const renderer = await GardenRenderer.deploy(await garden.getAddress());

    await (await web.setRenderer(await renderer.getAddress())).wait();

    return { garden, Garden, web, Web, owner, acc1, example1, showCritique };
  }

  describe("Deployment", function () {
    it("Should deploy", async function () {
      const { garden, showCritique } = await loadFixture(deployFixture);
      await expect(await garden.getAddress()).to.be.properAddress;
      await expect(await showCritique.getAddress()).to.be.properAddress;
    });
  });

  describe("Interaction", function () {
    it("Should allow owner to configure", async function () {
      const { owner, garden, showCritique } = await loadFixture(deployFixture);
      await showCritique.configure(await garden.getAddress());
      const text = await showCritique.text();
      expect(text).to.contain("</p>");
      expect(text).to.contain("thinks that");
      expect(text).to.contain(await owner.getAddress());
    });

    it("Should not allow non-owner to configure", async function () {
      const { acc1, garden, showCritique } = await loadFixture(deployFixture);
      await expect(
        showCritique.connect(acc1).configure(await garden.getAddress())
      ).to.be.revertedWithCustomError(
        showCritique,
        "Unauthorized"
      );
    });

    it("should allow anyone to critique", async function () {
      const { owner, garden, example1, showCritique } = await loadFixture(deployFixture);
      await showCritique.configure(await garden.getAddress());
      const criticAddress = await owner.getAddress();
      const workIndex = 0;
      const workAddress = (await garden.getSculptures())[workIndex];
      // Make sure we have assumed the correct Garden state.
      expect(workAddress).to.equal(await example1.getAddress());
      const workTitle = await example1.title();
      const workAuthor = (await example1.authors())[workIndex];
      await showCritique.critiqueWork(workIndex, workAddress, 10);
      const text = await showCritique.text();
      const critique = text.split("\n")[0];
      expect(text).to.contain(`<p>${criticAddress} thinks that <i><span style="white-space: nowrap;">${workTitle}</span></i> <span style="white-space: nowrap;">by ${workAuthor}</span> is <span style="white-space: nowrap;">triumphantly skilful.</span></p>`);
    })
  });
});
