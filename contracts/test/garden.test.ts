import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { EnsResolver, parseEther } from "ethers";
import hre from "hardhat";
import SHOWTEXT from "../../SHOWTEXT";
import ESSAY from "../../ESSAY";

import ESSAY from "../../ESSAY";
import SHOWTEXT from "../../SHOWTEXT";

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

    const ENSResolver = await hre.ethers.getContractFactory("ENSResolver");
    const ensResolver = await ENSResolver.deploy();

    const GardenRenderer = await hre.ethers.getContractFactory("GardenRenderer", {
      libraries: {
        GardenIndex: await gardenIndex.getAddress(),
        GardenEssay: await gardenEssay.getAddress(),
        ENSResolver: await ensResolver.getAddress(),
      },
    });
    const renderer = await GardenRenderer.deploy(await garden.getAddress(), await essay.getAddress(), await mod.getAddress());

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

    it("Should return flower info after donating", async function () {
      const { garden, web, owner } = await loadFixture(deployFixture);
      await owner.sendTransaction({
        to: await garden.getAddress(),
        value: parseEther("0.47"),
      })
      const responseJson = await web.request(["flower", "1"], []);
      expect(responseJson.statusCode).to.equal(200);

      const block = await hre.ethers.provider.getBlock("latest");
      const address = await owner.getAddress();
      const checksummedAddress = hre.ethers.getAddress(address);
      expect(JSON.parse(responseJson.body).planter).to.equal(checksummedAddress);
      expect(JSON.parse(responseJson.body).timestamp).to.equal(block?.timestamp);
      expect(web.request(["flower", "0"], [])).to.be.reverted;
      expect(web.request(["flower", "47"], [])).to.not.be.reverted;
      expect(web.request(["flower", "48"], [])).to.be.reverted;
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

  describe("Showtext & Essay", function () {
    it("Should allow setting the showtext on mod", async function () {
      const { garden, owner } = await loadFixture(deployFixture);
      const Mod = await hre.ethers.getContractFactory("Mod");
      const mod = await Mod.deploy();
      await mod.setText(SHOWTEXT, {
        from: owner
      });
      expect(await mod.text()).to.equal(SHOWTEXT);
    });

    it("Should allow setting the essay text", async function () {
      const { garden, owner } = await loadFixture(deployFixture);
      const Essay = await hre.ethers.getContractFactory("Essay");
      const essay = await Essay.deploy();
      await essay.setTextPt1(ESSAY.textPt1, {
        from: owner
      });
      await essay.setTextPt2(ESSAY.textPt2, {
        from: owner
      });
      await essay.setTitle(ESSAY.title, {
        from: owner
      });
    });
  });

  describe("ExternalWithdraw", async function () {
    it("Should allow withdrawing using the ExternalWithdraw contract", async function () {
      const { garden, owner, acc1 } = await loadFixture(deployFixture);
      const ExternalWithdraw = await hre.ethers.getContractFactory("ExternalWithdraw");
      const externalWithdraw = await ExternalWithdraw.deploy(await garden.getAddress());
      await owner.sendTransaction({
        to: await garden.getAddress(),
        value: parseEther("1.0"),
      })
      expect(await hre.ethers.provider.getBalance(await garden.getAddress())).to.equal(parseEther("1.0"));
      await garden.transferOwnership(await externalWithdraw.getAddress());
      await expect(garden.setSculptures([])).to.be.reverted;
      await expect(garden.withdraw(owner.address)).to.be.reverted;
      await externalWithdraw.withdraw(owner.address);
      expect(await hre.ethers.provider.getBalance(await garden.getAddress())).to.equal(0);

      // Once more
      await owner.sendTransaction({
        to: await garden.getAddress(),
        value: parseEther("1.23456789"),
      })
      expect(await hre.ethers.provider.getBalance(await garden.getAddress())).to.equal(parseEther("1.23456789"));
      const acc1BalancePre = await hre.ethers.provider.getBalance(acc1.address);
      await externalWithdraw.withdraw(acc1.address);
      expect(await hre.ethers.provider.getBalance(await garden.getAddress())).to.equal(0);
      expect(await hre.ethers.provider.getBalance(acc1.address)).to.equal(acc1BalancePre + parseEther("1.23456789"));
    });
  });

});
