import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("Garden", function () {
  async function deployFixture() {
    const signers = await hre.ethers.getSigners();
    const [owner, acc1, acc2, acc3, acc4, acc5, acc6] = signers;

    const SP = await hre.ethers.getContractFactory("SP");
    const sp = await SP.deploy();

    return { sp, SP, owner, acc1, acc2, acc3, acc4, acc5, acc6, signers };
  }

  describe("Deployment", function () {
    it("Should deploy", async function () {
      const { sp } = await loadFixture(deployFixture);
      await expect(await sp.getAddress()).to.be.properAddress;
    });
  });

  describe("ST", function () {
    it("Should deploy ST", async function () {
      const { sp, owner, acc1, acc2, acc3, acc4, acc5, acc6, signers } = await loadFixture(deployFixture);

      const ST = await hre.ethers.getContractFactory("ST");
      const stDeployment = await ST.deploy(await sp.getAddress(), owner.address);
      const st = await hre.ethers.getContractAt("ST", await stDeployment.getAddress());

      await owner.sendTransaction({
        to: await st.getAddress(),
        value: hre.ethers.parseEther("0.1"),
      });

      await acc1.sendTransaction({
        to: await st.getAddress(),
        value: hre.ethers.parseEther("0.2"),
      });

      await owner.sendTransaction({
        to: await st.getAddress(),
        value: hre.ethers.parseEther("0.1"),
      });

      await owner.sendTransaction({
        to: await st.getAddress(),
        value: hre.ethers.parseEther("0.1"),
      });

      await acc2.sendTransaction({
        to: await st.getAddress(),
        value: hre.ethers.parseEther("0.15"),
      });

      await acc3.sendTransaction({
        to: await st.getAddress(),
        value: hre.ethers.parseEther("0.15"),
      });

      await acc4.sendTransaction({
        to: await st.getAddress(),
        value: hre.ethers.parseEther("0.15"),
      });

      await acc5.sendTransaction({
        to: await st.getAddress(),
        value: hre.ethers.parseEther("0.15"),
      });

      await acc6.sendTransaction({
        to: await st.getAddress(),
        value: hre.ethers.parseEther("0.149999999999999999"),
      });

      for (let i = 6; i < 15; i++) {
        const acc = signers[i];
        await acc.sendTransaction({
          to: await st.getAddress(),
          value: hre.ethers.parseEther("0.15"),
        });
      }

      // console.log(await st.topContributors(10))
      expect(await st.topContributors(10)).not.to.be.reverted;

      const balanceBefore = await hre.ethers.provider.getBalance(await acc1.getAddress());
      const totalContributions = await st.totalContributions();
      await st.connect(owner).withdraw(await acc1.getAddress());
      const balanceAfter = await hre.ethers.provider.getBalance(await acc1.getAddress());
      expect(balanceAfter).to.equal(balanceBefore + totalContributions);
    });
  });
});
