// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

contract CreateTestAccount is Script {
    function run() public {
        // Generate a new private key
        uint256 privateKey = vm.envUint("NEW_PRIVATE_KEY");
        if (privateKey == 0) {
            privateKey = uint256(keccak256(abi.encodePacked(block.timestamp, "salt")));
        }
        
        // Derive the address
        address newAccount = vm.addr(privateKey);
        
        console.log("New Test Account Created:");
        console.log("Address:", newAccount);
        console.log("Private Key (hex):", vm.toString(privateKey));
        
        // Fund the account with some ETH
        vm.startBroadcast();
        payable(newAccount).transfer(1 ether);
        vm.stopBroadcast();
        
        console.log("Funded account with 1 ETH");
    }
} 