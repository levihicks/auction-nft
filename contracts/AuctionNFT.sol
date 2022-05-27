// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AuctionNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    constructor() ERC721("Auction NFT", "ANFT") {}

    function _baseURI() internal pure override returns (string memory) {
        return
            "https://gateway.pinata.cloud/ipfs/QmYzfRf8TKr2Z3GpfWWDfCvYPWm1XCne3aFgP6mT4JUWhr/";
    }

    function mint(address _to, uint256 _id) public onlyOwner {
        _safeMint(_to, _id);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return string(abi.encodePacked(super.tokenURI(id), ".json"));
    }
}
