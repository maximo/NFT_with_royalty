// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import 'OpenZeppelin/openzeppelin-contracts@4.0.0/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import "OpenZeppelin/openzeppelin-contracts@4.0.0/contracts/access/Ownable.sol";
import "OpenZeppelin/openzeppelin-contracts@4.0.0/contracts/utils/Counters.sol";

contract Unique is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _ids;

    event Created(address account, uint256 id);
    event Deleted(uint256 id);

    constructor(
        string memory name,
        string memory symbol
    ) 
    public ERC721(name, symbol) Ownable() { }

    function createMoment(
        address account,
        string memory uri 
    ) 
    public onlyOwner 
    returns (uint256 id) {
        uint256 _id = _ids.current();
        _ids.increment();
        _safeMint(account, _id);
        _setTokenURI(_id, uri);
        emit Created(account, _id);
        return _id;
    }

    function deleteMoment(uint256 id) 
        public onlyOwner {
        _burn(id);
        emit Deleted(id);
    }
}
