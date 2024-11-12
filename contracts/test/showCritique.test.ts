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

    const Essay = await hre.ethers.getContractFactory("Essay");
    const essay = await Essay.deploy();

    const ENSResolver = await hre.ethers.getContractFactory("ENSResolver");
    const ensResolver = await ENSResolver.deploy();

    const ShowCritique = await hre.ethers.getContractFactory("ShowCritique", {
      libraries: {
        ENSResolver: await ensResolver.getAddress(),
      },
    });
    const showCritique = await ShowCritique.deploy();

    const Web = await hre.ethers.getContractFactory("Web");
    const web = await Web.deploy();

    const Mod = await hre.ethers.getContractFactory("Mod");
    const mod = await Mod.deploy();

    const Garden = await hre.ethers.getContractFactory("Garden");
    const garden = await Garden.deploy([
      await example1.getAddress(),
      await example2.getAddress(),
      await example3.getAddress(),
      await example4.getAddress(),
    ], await web.getAddress(), await mod.getAddress());

    const GardenHTML = await hre.ethers.getContractFactory("GardenHTML");
    const gardenHTML = await GardenHTML.deploy();

    const GardenContributions = await hre.ethers.getContractFactory("GardenContributions");
    const gardenContributions = await GardenContributions.deploy();

    const GardenIndex = await hre.ethers.getContractFactory("GardenIndex", {
      libraries: {
        GardenHTML: await gardenHTML.getAddress(),
        GardenContributions: await gardenContributions.getAddress(),
      },
    });
    const gardenIndex = await GardenIndex.deploy();

    const GardenEssay = await hre.ethers.getContractFactory("GardenEssay", {
      libraries: {
        GardenHTML: await gardenHTML.getAddress(),
      },
    });
    const gardenEssay = await GardenEssay.deploy();

    const GardenRenderer = await hre.ethers.getContractFactory("GardenRenderer", {
      libraries: {
        GardenIndex: await gardenIndex.getAddress(),
        GardenEssay: await gardenEssay.getAddress(),
        ENSResolver: await ensResolver.getAddress(),
      },
    });
    const renderer = await GardenRenderer.deploy(await garden.getAddress(), await essay.getAddress(), await mod.getAddress());

    await (await web.setRenderer(await renderer.getAddress())).wait();

    return { showCritique, ShowCritique, garden, example1, Garden, web, Web, owner, acc1 };
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
        `OwnableUnauthorizedAccount`
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
      await showCritique.critiqueWork(workIndex, 10);
      const text = await showCritique.text();
      const critique = text.split("\n")[0];
      expect(text).to.contain(`<p><span class="address">${criticAddress}</span> thinks that <i><span style="white-space: nowrap;">${workTitle}</span></i> <span style="white-space: nowrap;">by ${workAuthor}</span> is <span style="white-space: nowrap;">triumphantly skilful.</span></p>`);
    });

    it("Should fail to ciritque with invalid work index", async function () {
      const { owner, garden, showCritique } = await loadFixture(deployFixture);
      await showCritique.configure(await garden.getAddress());
      const workIndex = 100;
      await expect(
        showCritique.critiqueWork(workIndex, 10)
      ).to.be.revertedWith(
        `invalid work (was the garden changed?)`
      );
    });

    it("Should fail to critique with invalid opinion", async function () {
      const { owner, garden, showCritique } = await loadFixture(deployFixture);
      await showCritique.configure(await garden.getAddress());
      const workIndex = 0;
      await expect(
        showCritique.critiqueWork(workIndex, 16)
      ).to.be.revertedWith(
        "invalid critical opinion (indices start at zero)"
      );
    });
  });
});
