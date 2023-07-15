// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19.0;

import {ERC721} from  "openzeppelin/token/ERC721/ERC721.sol";
import {IERC721} from "openzeppelin/token/ERC721/IERC721.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";

interface ISTERC721 is IERC721 {
    function tokenOf(address account) external view returns (uint256 tokeId);
    function mint(address to, uint256 tokenId) external;
}


contract STERC721 is ERC721("Stellarchy Planet", "STPL"), Ownable {
    address private _minter;

    mapping(address => uint256) private _tokens;

    function tokenOf(address account) external view returns (uint256 tokenId) {
        return _tokens[account];
    }

    function setMinter(address minter) external virtual onlyOwner {
        _minter = minter;
    }

    function mint(address to, uint256 tokenId) external virtual {
        require(msg.sender == _minter, "caller is not minter");
        require(balanceOf(to) == 0, "max planets per address is 1");
        _tokens[to] = tokenId;
        _safeMint(to, tokenId);
    }
}
