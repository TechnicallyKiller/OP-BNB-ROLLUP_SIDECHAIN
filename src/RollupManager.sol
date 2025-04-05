// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract RollupManager is Ownable {
    struct Batch {
        bytes32 hashdata;
        bytes32 stateData;
        uint256 timestamp;
        bool finalised;
        uint256 approvals;
    }

    mapping(uint256 => Batch) public batches;
    mapping(uint256 => mapping(address => bool)) public approvals;
    mapping(uint256 => bool) public isChallenged;

    mapping(address => bool) public validators;
    address[] public validatorList;

    uint256 public batchCount;
    uint256 public requiredApprovals;

    event BatchSubmitted(uint256 batchId, bytes32 batchHash, bytes32 stateData);
    event BatchFinalized(uint256 batchId);
    event ValidatorAdded(address validator);
    event ValidatorRemoved(address validator);
    event RequiredApprovalsChanged(uint256 newRequiredApprovals);
    event BatchApproved(uint256 batchId, address validator);
    event BatchChallenged(uint256 batchid, address val);

    constructor(uint256 _requiredApprovals) Ownable(msg.sender) {
        requiredApprovals = _requiredApprovals;
    }

    function submitBatch(bytes32 _batchHash, bytes32 _stateData) external {
        batches[batchCount] = Batch({
            hashdata: _batchHash,
            stateData: _stateData,
            timestamp: block.timestamp,
            finalised: false,
            approvals: 0
        });

        emit BatchSubmitted(batchCount, _batchHash, _stateData);
        batchCount++;
    }

    function approveBatch(uint256 batchId) external {
        require(validators[msg.sender], "Only validators can approve");
        require(batchId < batchCount, "Invalid batch ID");
        require(!approvals[batchId][msg.sender], "Validator already approved");
        require(!batches[batchId].finalised, "Batch already finalized");

        approvals[batchId][msg.sender] = true;
        batches[batchId].approvals++;

        emit BatchApproved(batchId, msg.sender);
    }

    function finalizeBatch(uint256 batchId) external {
        require(batchId < batchCount, "Invalid batch ID");
        require(!batches[batchId].finalised, "Batch already finalized");
        require(block.timestamp >= batches[batchId].timestamp + 7 days, "Challenge period active");
        require(batches[batchId].approvals >= requiredApprovals, "Not enough approvals");
        
    

        batches[batchId].finalised = true;
        emit BatchFinalized(batchId);
    }

    function addValidator(address _validator) external onlyOwner {
        require(!validators[_validator], "Validator already added");

        validators[_validator] = true;
        validatorList.push(_validator);

        emit ValidatorAdded(_validator);
    }

    function removeValidator(address _validator) external onlyOwner {
        require(validators[_validator], "Validator not found");

        validators[_validator] = false;
        emit ValidatorRemoved(_validator);
    }

    function setRequiredApprovals(uint256 _requiredApprovals) external onlyOwner {
        requiredApprovals = _requiredApprovals;
        emit RequiredApprovalsChanged(_requiredApprovals);
    }

    function challengeBatch(uint256 batchId) external payable {
    require(msg.value == 1 ether, "Challenge requires 1 ETH bond");
    require(!isChallenged[batchId], "Already challenged");
    
    isChallenged[batchId] = true;
    emit BatchChallenged(batchId, msg.sender);
}
}
