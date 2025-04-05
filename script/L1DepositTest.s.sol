// forge-deposit.t.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/L1Bridge.sol"; // adjust path if needed
import "../src/MyT.sol";      // your original ERC20

contract L1DepositTest is Script {
    address public constant L1_BRIDGE = 0xe493c34F27281d2626DeDEA73b25Da39d68Ba5c6; // 🔁 your deployed L1Bridge address
    address public constant MYT =0x1e214C401032d2FeA90278C20cc38F0738027253;       // 🔁 deployed MyT on Sepolia
    uint256 public constant DEPOSIT_AMOUNT = 1e18; // 1 MYT

    function run() external {
        uint256 key = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(key);

        IERC20(MYT).approve(L1_BRIDGE, DEPOSIT_AMOUNT);
        L1Bridge(L1_BRIDGE).depositToL2(DEPOSIT_AMOUNT);

        vm.stopBroadcast();
    }
}
