// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "openzeppelin/access/Ownable.sol";
import "openzeppelin/token/ERC20/ERC20.sol";

interface ISTERC20 is IERC20 {
    function mint(address caller, uint256 amount) external;
    function burn(address caller, uint256 amount) external;
}

contract STERC20 is ERC20, Ownable {
    address minter;

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function setMinter(address _minter) external virtual onlyOwner {
        minter = _minter;
    }

    function mint(address caller, uint256 amount) external virtual {
        require(msg.sender == minter, "caller is not minter");
        _mint(caller, amount);
    }

    function burn(address caller, uint256 amount) external virtual {
        require(msg.sender == minter, "caller is not minter");
        _burn(caller, amount);
    }
}