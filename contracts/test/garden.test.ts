import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { parseEther } from "ethers";
import hre from "hardhat";

describe("Garden", function () {
  async function deployFixture() {
    const [owner, acc1] = await hre.ethers.getSigners();

    const SP = await hre.ethers.getContractFactory("SP");
    const sp = await SP.deploy();

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

    const GardenIndex = await hre.ethers.getContractFactory("GardenIndex", {
      libraries: {
        GardenHTML: await gardenHTML.getAddress(),
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
      },
    });
    const renderer = await GardenRenderer.deploy(await garden.getAddress(), await essay.getAddress(), await mod.getAddress());

    await (await web.setRenderer(await renderer.getAddress())).wait();

    return { garden, Garden, web, Web, sp, SP, owner, acc1 };
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

  describe("Misc", function () {
    it("Should return all artist names including curator", async function () {
      const { garden, owner } = await loadFixture(deployFixture);
      const names = await garden.authors();
      expect(names).to.have.length(5);
    });
  });

  describe("FlowerGuestbook", function () {
    it("Should allow guests to sign", async function () {
      const { garden, owner, acc1 } = await loadFixture(deployFixture);

      await acc1.sendTransaction({
        to: await garden.getAddress(),
        value: parseEther("0.01"),
      })
      expect(await garden.flowers()).to.equal(1);
      expect(await garden.flower(1)).to.equal(await acc1.getAddress());
      expect(await garden.flowersPlanted(await acc1.getAddress())).to.equal(1n);

      await owner.sendTransaction({
        to: await garden.getAddress(),
        value: parseEther("150.0"),
      })

      expect(await garden.flowers()).to.equal(15001);
      expect(await garden.flower(15001)).to.equal(await owner.getAddress());
      expect(await garden.flowersPlanted(await owner.getAddress())).to.equal(15000);
      expect(await garden.flower(2,{
        gasLimit: 60_000_000
      })).to.equal(await owner.getAddress());

    });

    it("Should allow withdrawing", async function () {
      const { garden, owner, acc1 } = await loadFixture(deployFixture);

      await owner.sendTransaction({
        to: await garden.getAddress(),
        value: parseEther("1.0"),
      })

      const balance = await hre.ethers.provider.getBalance(await acc1.getAddress());
      const gardenBalance = await hre.ethers.provider.getBalance(await garden.getAddress());

      await garden.withdraw(await acc1.getAddress());

      expect(await hre.ethers.provider.getBalance(await acc1.getAddress())).to.equal(balance+gardenBalance);
      expect(await hre.ethers.provider.getBalance(await garden.getAddress())).to.equal(0);
    });
  });
});
