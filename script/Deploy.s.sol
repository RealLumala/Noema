// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/NoemaIP.sol";

contract DeployScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the contract
        NoemaIP noemaIP = new NoemaIP();
        
        // Log the deployed address
        console2.log("NoemaIP deployed to:", address(noemaIP));

        // Stop broadcasting
        vm.stopBroadcast();
    }
} 