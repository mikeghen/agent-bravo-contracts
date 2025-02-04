// SPDX-License-Identifier: Apache 2.0
pragma solidity ^0.8.22;

import {Test} from "forge-std/Test.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {AgentBravoGovernor} from "src/AgentBravoGovernor.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import {ICompoundTimelock} from "@openzeppelin/contracts/vendor/compound/ICompoundTimelock.sol";

/// @dev A dummy implementation of IVotes for testing purposes.
contract DummyVotes is IVotes {
    function getVotes(address) external pure override returns (uint256) {
        return 0;
    }
    function getPastVotes(address, uint256) external pure override returns (uint256) {
        return 0;
    }
    function getPastTotalSupply(uint256) external pure override returns (uint256) {
        return 0;
    }
    function delegates(address) external pure override returns (address) {
        return address(0);
    }
    function delegate(address) external override {
        // dummy implementation
    }
    function delegateBySig(
        address,
        uint256,
        uint256,
        uint8,
        bytes32,
        bytes32
    ) external override {
        // dummy implementation
    }
}

/// @dev A dummy implementation of ICompoundTimelock for testing purposes.
contract DummyCompoundTimelock is ICompoundTimelock {
    function delay() external pure override returns (uint256) {
        return 0;
    }
    function queueTransaction(
        address,
        uint256,
        string calldata,
        bytes calldata,
        uint256
    ) external pure override returns (bytes32) {
        return keccak256(bytes("dummy"));
    }
    function executeTransaction(
        address,
        uint256,
        string calldata,
        bytes calldata,
        uint256
    ) external payable override returns (bytes memory) {
        return "";
    }
    function cancelTransaction(
        address,
        uint256,
        string calldata,
        bytes calldata,
        uint256
    ) external pure override {
        // nothing to do here
    }
    receive() external payable override {}
    function GRACE_PERIOD() external pure override returns (uint256) {
        return 0;
    }
    function MINIMUM_DELAY() external pure override returns (uint256) {
        return 0;
    }
    function MAXIMUM_DELAY() external pure override returns (uint256) {
        return 0;
    }
    function acceptAdmin() external override {}
    function admin() external pure override returns (address) {
        return address(0);
    }
    function pendingAdmin() external pure override returns (address) {
        return address(0);
    }
    function queuedTransactions(bytes32) external pure override returns (bool) {
        return false;
    }
    function setDelay(uint256) external override {}
    function setPendingAdmin(address) external override {}
}

/// @title AgentBravoGovernorTest
/// @dev Tests that the governor's proxy is properly deployed and initialized.
contract AgentBravoGovernorTest is Test {
    AgentBravoGovernor public instance;
    DummyVotes public dummyVotes;
    DummyCompoundTimelock public dummyTimelock;

    function setUp() public {
        // Deploy dummy contracts for IVotes and ICompoundTimelock.
        dummyVotes = new DummyVotes();
        dummyTimelock = new DummyCompoundTimelock();

        // Set an admin address.
        address admin = vm.addr(1);

        // Deploy the UUPS proxy for AgentBravoGovernor.
        address proxy = Upgrades.deployUUPSProxy(
            "AgentBravoGovernor.sol",
            abi.encodeCall(AgentBravoGovernor.initialize, (dummyVotes, dummyTimelock, admin))
        );

        // Cast the proxy address to a payable address to remove the explicit conversion error.
        instance = AgentBravoGovernor(payable(proxy));
    }

    function testName() public view {
        // The governor was initialized with the name "AgentBravoGovernor".
        assertEq(instance.name(), "AgentBravoGovernor");
    }
} 