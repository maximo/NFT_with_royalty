// 1155WithRoyalties.sol
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC1155WithRoyalties is ERC1155, Ownable {
    using SafeMath for *;

    // Price per token, set by the seller or an operator
    mapping (uint256 => int256) private _prices;

    mapping (uint256 => address) private _owners;
    mapping (uint256 => address) private _buyers;

    mapping (uint256 => address) private _royaltyAddresses;
    mapping (uint256 => uint16) private _royaltyBasisPoints;

    // Events specific to this contract
    event Buy(address from, address to, uint256 tokenId, int256 price, uint256 fee, uint256 balance);

    event SetRoyaltyAddress(address changedBy, address royaltyAddress);

    constructor (string memory uri_) ERC1155(uri_) {
        _setURI(uri_);
    }

    function buyToken(address to, uint256 tokenId) external payable {
        require(_prices[tokenId] > 0, "Price has not been set for token");
        require(int256(msg.value) > _prices[tokenId], "Sent eth does not meet price");
        require(_buyers[tokenId] == msg.sender, "Only the designated buyer can purchase the token");

        uint256 fee = msg.value.mul(_royaltyBasisPoints[tokenId]).div(100 * 100);

        (bool feeSuccess, ) = _royaltyAddresses[tokenId].call{value: fee}("");
        require(feeSuccess, "Fee transfer failed");

        address seller = ownerOf(tokenId);
        uint256 balance = msg.value.sub(fee);
        (bool sellerSuccess, ) = seller.call{value: balance}("");
        require(sellerSuccess, "Seller transfer failed");

        address owner = ownerOf(tokenId);
        safeTransferFrom(owner, to, tokenId, 1, "");

        // Reset price/buyer information
        _prices[tokenId] = -1;
        _buyers[tokenId] = address(0);

        emit Buy(owner, to, tokenId, _prices[tokenId], fee, balance);
    }

    function mintToken(address account, uint256 id, uint256 amount) public {
        _mint(account, id, amount, "");
    }

    function setRoyaltyAddress(address royaltyAddress, uint256 tokenId) public virtual onlyOwner {
        _royaltyAddresses[tokenId] = royaltyAddress;

        emit SetRoyaltyAddress(msg.sender, royaltyAddress);
    }

    function getRoyaltyAddress(uint256 tokenId) public view returns (address) {
        return _royaltyAddresses[tokenId];
    }

    // Set a price that must be met for the token to be transferred
    function setPrice(uint256 tokenId, address buyer, int256 price) public virtual {
        require(_isOwner(tokenId), "ERC721: setPrice caller is not owner");
        require(price >= 0, "Unable to set negative price");

        _prices[tokenId] = price;
        _buyers[tokenId] = buyer;
    }

    function getPrice(uint256 tokenId) public view virtual returns (int256) {
        return _prices[tokenId];
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        override
        internal
        virtual
    {
        for (uint i = 0; i < ids.length; i++) {
            uint256 tokenId = ids[i];
            uint256 amount = amounts[i];

            require(amount == 1, "Only NFTs are supported in this contract");
            if (from != address(0)) {
                require(_prices[tokenId] > 0, "Price has not been set for token");
            }

            _owners[tokenId] = to;
        }
    }

    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        return _owners[tokenId];
    }

    function _isOwner(uint256 tokenId) internal view returns (bool) {
        return ownerOf(tokenId) == msg.sender;
    }
}
