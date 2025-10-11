// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Engine.sol";
import {TestToken} from "../src/TestToken.sol";

contract DeployEngine is Script {
    function run() external {
        vm.startBroadcast();
        
        // Deploy test token with 1 million tokens (18 decimals)
        // TestToken token = new TestToken(1000000 * 10**18);
        
        // Deploy engine contract with token address
        Engine engine = new Engine(0xc015Efb1CB95543687f46aEDB1fe062627B893B4);
        
        // console.log("TestToken deployed at:", address(token));
        console.log("Engine deployed at:", address(engine));
        
        vm.stopBroadcast();
    }
}