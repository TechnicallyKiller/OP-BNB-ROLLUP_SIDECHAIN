// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract MyT is ERC20,Ownable{
    constructor() ERC20("MyT","MYT")  Ownable(msg.sender)  {
        _mint(msg.sender, 1_000_000 * 10**decimals());
    }

    function mint(address user, uint256 amount) public {
        _mint(user, amount);
    }
}