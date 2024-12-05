//SPDC-License-Identifier: MIT
//1. Deploy mock when we are on a local anvil chain
//2. Keep track of contract addresses across different chains
// Sepolia ETH/USD
// Mainnet ETH/USD


pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script{

    uint8 public  constant DECIMALS = 8;
    int256 public  constant INITIAL_PRICE = 2000e8;

    // if we are on a local anvil chain, we deploy the mock
    //Otherwise, we grab the existing contract addresses in the live network
    NetworkConfig public activeNetworkConfig;
    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if(block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        }
        else if(block.chainid == 1) {
            activeNetworkConfig = getMainNetEthConfig();
        }
        else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }
    function getSepoliaEthConfig() public pure returns(NetworkConfig memory) {
        // price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainNetEthConfig() public pure returns(NetworkConfig memory) {
        // price feed address
        NetworkConfig memory MainNetEthConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return MainNetEthConfig;
    }

    function getOrCreateAnvilEthConfig() public  returns(NetworkConfig memory) {
        // price feed address
        if(activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        // 1. deploy the mock
        // 2. return the mock address

        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilEthConfig = NetworkConfig({
            priceFeed: address(mockV3Aggregator)
        });
        return anvilEthConfig;
    }
}