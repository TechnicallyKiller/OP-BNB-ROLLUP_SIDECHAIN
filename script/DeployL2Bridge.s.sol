// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/L2Bridge.sol"; // Adjust path as needed
import "../src/MyTWrapped.sol"; // Optional: if you want to transfer ownership here

contract DeployL2Bridge is Script {
    function run() external {
        
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

       
        vm.startBroadcast(deployerPrivateKey);

       
        address myTWrapped = vm.envAddress("MYT_WRAPPED_ADDRESS");

       
        L2Bridge l2Bridge = new L2Bridge(myTWrapped);

        console.log("L2Bridge deployed to:", address(l2Bridge));

        

        vm.stopBroadcast();
    }
}
