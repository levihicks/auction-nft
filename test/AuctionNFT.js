const { expect } = require("chai");

describe("AuctionNFT", function () {
  let auctionNFT, auctionHouse, signers;
  before(async function () {
    const AuctionNFTFactory = await ethers.getContractFactory("AuctionNFT");
    auctionNFT = await AuctionNFTFactory.deploy();
    const AuctionHouseFactory = await ethers.getContractFactory("AuctionHouse");
    auctionHouse = await AuctionHouseFactory.deploy(auctionNFT.address);
    signers = await ethers.getSigners();
  });
  it("successfully transfers ownership to AuctionHouse contract", async function () {
    expect(await auctionNFT.owner()).to.equal(signers[0].address);
    await auctionNFT.transferOwnership(auctionHouse.address);
    expect(await auctionNFT.owner()).to.equal(auctionHouse.address);
  });
  it("disallows mint when not called by AuctionHouse contract", async function () {
    await expect(auctionNFT.connect(signers[1]).mint(signers[1].address, 1)).to
      .be.reverted;
  });
});
