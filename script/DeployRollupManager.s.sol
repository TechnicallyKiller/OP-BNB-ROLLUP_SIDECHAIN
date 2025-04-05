// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "../lib/forge-std/src/Script.sol";
import "../src/RollupManager.sol";

contract DeployRollUp is Script{
    RollupManager public rollupManager;
    function setUp() public{}
    function run() public {
        vm.startBroadcast();
        rollupManager= new RollupManager(3);
        vm.stopBroadcast();
    }
}