// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/L1Bridge.sol";

contract DeployL1Bridge is Script {
    function run() external {
        address myT =0x1e214C401032d2FeA90278C20cc38F0738027253;

        vm.startBroadcast();
        new L1Bridge(myT);
        vm.stopBroadcast();
    }
}
