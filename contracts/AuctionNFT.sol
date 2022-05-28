// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title AuctionNFT
/// @author Levi Hicks
/// @notice example NFT to be minted via an auction house platform
contract AuctionNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    /// === Constructor ===

    constructor() ERC721("Auction NFT", "ANFT") {}

    /// === Functions ===

    /// @notice returns base URI
    /// @return base URI string
    function _baseURI() internal pure override returns (string memory) {
        return
            "https://gateway.pinata.cloud/ipfs/QmYzfRf8TKr2Z3GpfWWDfCvYPWm1XCne3aFgP6mT4JUWhr/";
    }

    /// @notice mints a new token
    /// @dev should be restricted to AuctionHouse contract (owner)
    /// @param _to recipient of the new token
    /// @param _id id of the new token
    function mint(address _to, uint256 _id) public onlyOwner {
        _safeMint(_to, _id);
    }

    /// @notice retrieves URI of token
    /// @param _id id of token to return URI for
    /// @return token URI string
    function tokenURI(uint256 _id)
        public
        view
        override
        returns (string memory)
    {
        return string(abi.encodePacked(super.tokenURI(_id), ".json"));
    }
}
