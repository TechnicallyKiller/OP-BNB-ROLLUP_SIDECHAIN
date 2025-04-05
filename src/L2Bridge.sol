// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./MyTWrapped.sol";

contract L2Bridge is Ownable{
    MyTWrapped public MytWrapped;
    
    mapping(bytes32 => bool) public mintProcessed;

    mapping(address => uint256) public nonces;

    
    event MintedOnL2(address indexed user, uint256 amount, uint256 nonce);
    event WithdrawalInitiated(address indexed user, uint256 amount, uint256 nonce);

     constructor(address _myTWrapped) Ownable(msg.sender) {
        MytWrapped = MyTWrapped(_myTWrapped);
    }

    function MintonL2(address user, uint256 amount, uint256 nonce) external onlyOwner {
        require(user!= address(0) , "Invalid User");
        require(amount>0,"amount must be >0");
        bytes32 mintID= keccak256(abi.encodePacked(user,amount,nonce));

        require(!mintProcessed[mintID],"already minted");
        mintProcessed[mintID]=true;
        MytWrapped.mint(user,amount);
        emit MintedOnL2(user,amount,nonce);
    }
     function withdrawToL1(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");

        uint256 nonce = nonces[msg.sender];
        nonces[msg.sender]++;

        MytWrapped.burnFrom(msg.sender, amount);
        emit WithdrawalInitiated(msg.sender, amount, nonce);
    }

}