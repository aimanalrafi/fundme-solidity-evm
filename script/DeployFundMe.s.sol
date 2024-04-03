// SPDX-License-Identifier: Mit
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();

        vm.startBroadcast();
        // since the struct has only one param, no need to access it by name
        FundMe fundMe = new FundMe(helperConfig.activeNetworkConfig());
        vm.stopBroadcast();
        return fundMe;
    }
}
