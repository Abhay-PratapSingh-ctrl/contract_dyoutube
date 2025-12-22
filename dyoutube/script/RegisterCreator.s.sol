// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/CreatorHub.sol";

contract RegisterCreator is Script {
    function run() external {
        address CREATOR_HUB = vm.envAddress("CREATOR_HUB");

        vm.startBroadcast();

        CreatorHub(CREATOR_HUB).registerCreator("Alice", "Web3 Content Creator", "ipfs://creator-metadata");

        vm.stopBroadcast();
    }
}
