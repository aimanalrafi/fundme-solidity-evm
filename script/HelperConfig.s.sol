// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * 1. Deploy mocks when on local anvil chain
 * 2. Keep track of the contract address across different chains
 *    - Sepolia ETH/USD
 *    - Mainnet ETH/USD
 */

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;
    // We don't like magic numbers, so use constants where necessary
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed
    }

    constructor() {
        // 11155111 is the chain id of Sepolia
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address of sepolia

        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });

        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address of mainnet
        NetworkConfig memory ethMainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });

        return ethMainnetConfig;
    }

    // mock price feed address. Deploy own price feed contract
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // address(0) is default value of address. So if condittion checks if the price feed has been set or not
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        //deploys mocked price feed contract
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });

        return anvilConfig;
    }
}
