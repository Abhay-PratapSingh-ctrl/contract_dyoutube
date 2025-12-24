// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/CreatorHub.sol";
import "../src/X402AccessManager.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerKey);

        CreatorHub creatorHub = new CreatorHub();
        console2.log("CreatorHub deployed at:", address(creatorHub));

        // USDC on Base Sepolia (official)
        address USDC = 0x036CbD53842c5426634e7929541eC2318f3dCF7e;

        X402AccessManager accessManager = new X402AccessManager(address(creatorHub), USDC, vm.addr(deployerKey));

        console2.log("AccessManager deployed at:", address(accessManager));

        vm.stopBroadcast();
    }
}
