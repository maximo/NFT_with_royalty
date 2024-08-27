// 721WithRoyalties.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721WithRoyalties is ERC721, Ownable {
    using SafeMath for *;

    // Price per token, set by the seller or an operator
    mapping (uint256 => uint256) private prices;

    address _royaltyAddress;
    uint16 _royaltyBasisPoints;

    // Events specific to this contract
    event Buy(address from, address to, uint256 tokenId, uint256 price, uint256 fee, uint256 balance);

    event SetRoyaltyAddress(address changedBy, address royaltyAddress);

    constructor(address royaltyAddress, uint16 royaltyBasisPoints string memory nftName, string memory nftSymbol) ERC721(nftName, nftSymbol) {
        require(royaltyAddress != address(0), "Royalty address was not set");

        _royaltyAddress = royaltyAddress;
        _royaltyBasisPoints = royaltyBasisPoints;

        _safeMint(0x5AF5cE62295c99FC3E676D8EbA299A906429566A, 1);
        _safeMint(0x5AF5cE62295c99FC3E676D8EbA299A906429566A, 2);
    }

    function buyToken(address from, address to, uint256 tokenId) external payable {
        require(prices[tokenId] > 0, "Price has not been set for token");
        require(msg.value >= prices[tokenId], "Sent eth does not meet price");

        // uint256 percentage = _royaltyBasisPoints.div(100 * 100);
        // uint256 fee = msg.value.mul(percentage);
        uint256 fee = msg.value.mul(_royaltyBasisPoints).div(100 * 100);

        (bool feeSuccess, ) = _royaltyAddress.call{value: fee}("");
        require(feeSuccess, "Fee transfer failed");

        address seller = ownerOf(tokenId);
        uint256 balance = msg.value.sub(fee);
        (bool sellerSuccess, ) = seller.call{value: balance}("");
        require(sellerSuccess, "Seller transfer failed");

        safeTransferFrom(from, to, tokenId);

        // Reset price information
        prices[tokenId] = 0;

        emit Buy(from, to, tokenId, prices[tokenId], fee, balance);
    }

    function setRoyaltyAddress(address royaltyAddress) public virtual onlyOwner {
        _royaltyAddress = royaltyAddress;

        emit SetRoyaltyAddress(msg.sender, royaltyAddress);
    }

    function getRoyaltyAddress() public view returns (address) {
        return _royaltyAddress;
    }

    // Set a price that must be met for the token to be transferred
    function setPrice(uint256 tokenId, address buyer, uint256 price) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: setPrice caller is not owner nor approved");

        prices[tokenId] = price;
        approve(buyer, tokenId);
    }

    function getPrice(uint256 tokenId) public view virtual returns (uint256) {
        return prices[tokenId];
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) override internal virtual {
        if (from != address(0)) {
            require(prices[tokenId] > 0, "Price has not been set for token");
        }
    }
}