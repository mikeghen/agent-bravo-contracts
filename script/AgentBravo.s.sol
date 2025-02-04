// SPDX-License-Identifier: Apache 2.0
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {AgentBravo} from "src/AgentBravo.sol";

contract AgentBravoScript is Script {
  function setUp() public {}

  function run() public {
    // TODO: Set addresses for the variables below, then uncomment the following section:
    /*
    vm.startBroadcast();
    address defaultAdmin = <Set defaultAdmin address here>;
    address pauser = <Set pauser address here>;
    address minter = <Set minter address here>;
    address upgrader = <Set upgrader address here>;
    address proxy = Upgrades.deployUUPSProxy(
      "AgentBravo.sol",
      abi.encodeCall(AgentBravo.initialize, (defaultAdmin, pauser, minter, upgrader))
    );
    AgentBravo instance = AgentBravo(proxy);
    console.log("Proxy deployed to %s", address(instance));
    vm.stopBroadcast();
    */
  }
}
