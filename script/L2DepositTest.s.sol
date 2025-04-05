// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/L2Bridge.sol"; // adjust path
import "../src/MyTWrapped.sol"; // wrapped token

contract L2WithdrawTest is Script {
    address public constant L2_BRIDGE =0x903c9b908a9FCb1C799ED97FEa382811CFB77C6c ;     // 🔁 L2Bridge on opBNB
    address public constant WRAPPED = address(0x36dE78549bC959da408A9307E651Dd97a9E32d12);


    uint256 public constant WITHDRAW_AMOUNT = 1e18; // 1 token

    function run() external {
        uint256 key = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(key);

        L2Bridge(L2_BRIDGE).withdrawToL1(WITHDRAW_AMOUNT); // or whatever method you use

        vm.stopBroadcast();
    }
}