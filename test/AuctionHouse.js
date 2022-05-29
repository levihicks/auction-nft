const { expect } = require("chai");

describe("AuctionHouse", function () {
  let auctionNFT, auctionHouse, signers;
  before(async function () {
    const AuctionNFTFactory = await ethers.getContractFactory("AuctionNFT");
    auctionNFT = await AuctionNFTFactory.deploy();
    const AuctionHouseFactory = await ethers.getContractFactory("AuctionHouse");
    auctionHouse = await AuctionHouseFactory.deploy(auctionNFT.address);
    await auctionNFT.transferOwnership(auctionHouse.address);
    signers = await ethers.getSigners();
  });
  describe("Bidding", function () {
    it("can bid successfully", async function () {
      await auctionHouse.bid({ value: ethers.utils.parseEther("1.0") });
      const currentAuction = await auctionHouse.auctions(1);
      expect(currentAuction.topBidder).to.equal(signers[0].address);
      expect(currentAuction.topBid).to.equal(ethers.utils.parseEther("1.0"));
    });
    it("user is refunded after being outbid", async function () {
      const previousUserBalance = await signers[0].getBalance();
      await auctionHouse
        .connect(signers[1])
        .bid({ value: ethers.utils.parseEther("1.1") });
      const userBalance = await signers[0].getBalance();
      expect(userBalance.sub(previousUserBalance)).to.equal(
        ethers.utils.parseEther("1.0")
      );
    });
    it("can't bid after auction ends", async function () {
      await network.provider.send("evm_increaseTime", [3600]);
      await expect(auctionHouse.bid({ value: ethers.utils.parseEther("2.0") }))
        .to.be.reverted;
    });
  });
  describe("Settlement", function () {
    before(async function () {
      await auctionHouse.settleAuction();
      await auctionHouse.bid({ value: ethers.utils.parseEther("1.0") });
    });
    it("can't settle before auction ends", async function () {
      await expect(auctionHouse.settleAuction()).to.be.reverted;
    });
    it("NFT minted to winner after settlement", async function () {
      await network.provider.send("evm_increaseTime", [3600]);
      await auctionHouse.settleAuction();
      expect(await auctionNFT.ownerOf(2)).to.equal(signers[0].address);
    });
  });
});
