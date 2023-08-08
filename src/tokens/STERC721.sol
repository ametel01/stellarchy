// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19 .0;

import {ERC721} from "openzeppelin/token/ERC721/ERC721.sol";
import {IERC721} from "openzeppelin/token/ERC721/IERC721.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";

interface ISTERC721 is IERC721 {
    function mint(address to, uint256 tokenId) external;

    function tokenOf(address account) external view returns (uint256 tokeId);
}

contract STERC721 is ERC721, Ownable {
    string public baseTokenURI;

    address private _minter;

    mapping(address => uint256) private _tokens;

    constructor() ERC721("Stellarchy Planet", "STPL") {}

    function transferFrom(address from, address to, uint256 tokenId) public virtual override(ERC721) {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        require(balanceOf(to) == 0, "Max planets per account is 1");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)
        public
        virtual
        override(ERC721)
    {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        require(balanceOf(to) == 0, "Max planets per account is 1");
        _safeTransfer(from, to, tokenId, data);
    }

    function mint(address to, uint256 tokenId) external virtual {
        require(msg.sender == _minter, "caller is not minter");
        require(balanceOf(to) == 0, "max planets per address is 1");
        _tokens[to] = tokenId;
        _safeMint(to, tokenId);
    }

    function setMinter(address minter) external virtual onlyOwner {
        _minter = minter;
    }

    function setBaseUri(string memory uri) external onlyOwner {
        baseTokenURI = uri;
    }

    function baseURI() external view virtual returns (string memory) {
        return baseTokenURI;
    }

    function tokenOf(address account) external view returns (uint256 tokenId) {
        return _tokens[account];
    }
}
