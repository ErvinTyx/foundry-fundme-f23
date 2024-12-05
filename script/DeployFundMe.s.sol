//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {FundMe} from "../src/FundMe.sol";
import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {

    function run() external returns(FundMe){
        // Before starting the broadcast -> Not a "real" tx
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        // After startBroadcast -> "real" tx
        vm.startBroadcast();
        FundMe fundme = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundme;
    }

}