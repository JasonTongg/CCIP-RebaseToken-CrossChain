// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {BridgeTokens} from "../src/Bridge.sol";

contract BridgeDeploy is Script {
    function run() public {
        vm.startBroadcast();
        new BridgeTokens();
        vm.stopBroadcast();
    }
}
