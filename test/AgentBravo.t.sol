// SPDX-License-Identifier: Apache 2.0
pragma solidity ^0.8.22;

import {Test} from "forge-std/Test.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {AgentBravo} from "src/AgentBravo.sol";

contract AgentBravoTest is Test {
  AgentBravo public instance;

  function setUp() public {
    address defaultAdmin = vm.addr(1);
    address pauser = vm.addr(2);
    address minter = vm.addr(3);
    address upgrader = vm.addr(4);
    address proxy = Upgrades.deployUUPSProxy(
      "AgentBravo.sol",
      abi.encodeCall(AgentBravo.initialize, (defaultAdmin, pauser, minter, upgrader))
    );
    instance = AgentBravo(proxy);
  }

  function testName() public view {
    assertEq(instance.name(), "Agent Bravo");
  }
}
