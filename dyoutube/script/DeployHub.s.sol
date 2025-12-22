// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/CreatorRegistry.sol";
import "../src/CreatorHub.sol";
import "../src/ContentAccessManager.sol";

contract DeployHub is Script {
    function run() external {
        vm.startBroadcast();

        CreatorHub creatorHub = new CreatorHub();
        // deploying a brand new CreatorHub on chain
        ContentAccessManager accessManager = new ContentAccessManager(address(creatorHub));

        vm.stopBroadcast();
    }
}
