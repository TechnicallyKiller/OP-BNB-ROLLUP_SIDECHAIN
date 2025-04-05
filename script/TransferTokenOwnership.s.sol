// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MyTWrapped.sol";

contract TransferTokenOwnership is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        address wrappedToken = vm.envAddress("MYT_WRAPPED");
        address l2Bridge = vm.envAddress("L2_BRIDGE");

        MyTWrapped(wrappedToken).transferOwnership(l2Bridge);

        console.log("Transferred MyTWrapped ownership to L2Bridge:", l2Bridge);

        vm.stopBroadcast();
    }
}
