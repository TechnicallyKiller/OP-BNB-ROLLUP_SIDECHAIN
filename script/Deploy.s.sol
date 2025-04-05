// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "../lib/forge-std/src/Script.sol";
import {MyT} from "../src/MyT.sol";

contract DeployScript is Script {
    MyT public myt;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        myt = new MyT();

        vm.stopBroadcast();
    }
}
