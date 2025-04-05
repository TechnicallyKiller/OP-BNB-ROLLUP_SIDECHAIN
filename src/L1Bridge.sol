// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract L1Bridge is Ownable{
    event DepositIntiation(address sender, uint256 amount, uint nonce);
    event TokenReleased(address user , uint256 amount, uint256 nonce);

    mapping(address=>uint256) public nonces;
    mapping(bytes32=>bool) public withdrawl_processed;

    IERC20 public myT;
    constructor(address _myt) Ownable(msg.sender){
        myT=IERC20(_myt);

    }

    function depositToL2(uint256 amount) external{
        require(amount>0,"zero not accepted");
        uint256 nonce = nonces[msg.sender];
        nonces[msg.sender]++;

        require(myT.transferFrom(msg.sender,address(this),amount),"not completed");

        emit DepositIntiation(msg.sender,amount,nonce);

    }

    function releaseOnL1(address user, uint256 amount, uint256 nonce) external onlyOwner{
        require(user != address(0), "need a address");
        require(amount>0,"Amount>0");

        bytes32 withdrawlId= keccak256(abi.encodePacked(user,amount,nonce));
        require(!withdrawl_processed[withdrawlId],'already done');
        withdrawl_processed[withdrawlId]=true;

        require(myT.transfer(user,amount),'TRANSFER FAILED');

        emit TokenReleased(user,amount,nonce);


    }
}