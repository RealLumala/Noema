// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/NoemaIP.sol";

contract NoemaIPScript is Script {
    error InvalidPrivateKey();
    error DeploymentFailed();

    function setUp() public {}

    function run() public {
        // Get deployment configuration
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        if (deployerPrivateKey == 0) revert InvalidPrivateKey();

        // Get network configuration
        string memory network = vm.envString("NETWORK");
        string memory rpcUrl = vm.envString("RPC_URL");
        
        console2.log("Deploying NoemaIP to network:", network);
        console2.log("Using RPC URL:", rpcUrl);

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        try new NoemaIP() returns (NoemaIP noemaIP) {
            vm.stopBroadcast();
            
            // Log deployment information
            console2.log("=== Deployment Successful ===");
            console2.log("Network:", network);
            console2.log("Contract Address:", address(noemaIP));
            console2.log("Deployer Address:", vm.addr(deployerPrivateKey));
            console2.log("Block Number:", block.number);
            console2.log("Gas Used:", block.gaslimit);
        } catch {
            vm.stopBroadcast();
            revert DeploymentFailed();
        }
    }
} 