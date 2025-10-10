// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {Vault} from "../src/Vault.sol";
import {IRebaseToken} from "../src/interfaces/IRebaseToken.sol";
import {RebaseToken} from "../src/RebaseToken.sol";
import {RebaseTokenPool} from "../src/RebaseTokenPool.sol";
import {CCIPLocalSimulatorFork, Register} from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";
import {IERC20} from "@ccip/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {RegistryModuleOwnerCustom} from "@ccip/contracts/src/v0.8/ccip/tokenAdminRegistry/RegistryModuleOwnerCustom.sol";
import {TokenAdminRegistry} from "@ccip/contracts/src/v0.8/ccip/tokenAdminRegistry/TokenAdminRegistry.sol";

contract TokenAndPoolDeployer is Script{
    function run(address _rmnProxy, address _router, address _registryModuleOwner, address _tokenAdminRegistry) public returns (RebaseToken token, RebaseTokenPool pool) {
        CCIPLocalSimulatorFork ccipLocalSimulatorFork = new CCIPLocalSimulatorFork();
        Register.NetworkDetails memory networkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid);

        address rmnProxyAddress = _rmnProxy != address(0) ? _rmnProxy : networkDetails.rmnProxyAddress;
        address routerAddress   = _router != address(0) ? _router : networkDetails.routerAddress;
        address registryModuleOwnerCustomAddress = _registryModuleOwner != address(0) ? _registryModuleOwner : networkDetails.registryModuleOwnerCustomAddress; 
        address tokenAdminRegistryAddress = _tokenAdminRegistry != address(0) ? _tokenAdminRegistry : networkDetails.tokenAdminRegistryAddress; 

        console2.log(rmnProxyAddress);
        console2.log(routerAddress);

        vm.startBroadcast();
        token = new RebaseToken();
        pool = new RebaseTokenPool(IERC20(address(token)), new address[](0), rmnProxyAddress, routerAddress);
        token.grantMintAndBurnRole(address(pool));
        RegistryModuleOwnerCustom(registryModuleOwnerCustomAddress).registerAdminViaOwner(address(token));
        TokenAdminRegistry(tokenAdminRegistryAddress).acceptAdminRole(address(token));
        TokenAdminRegistry(tokenAdminRegistryAddress).setPool(address(token),address(pool));
        vm.stopBroadcast();
    }
}

contract VaultDeployer is Script {
    function run(address _rebaseToken) public returns (Vault vault){
        vm.startBroadcast();
        vault = new Vault(IRebaseToken(_rebaseToken));
        IRebaseToken(_rebaseToken).grantMintAndBurnRole(address(vault));
        vm.stopBroadcast();
    }
}