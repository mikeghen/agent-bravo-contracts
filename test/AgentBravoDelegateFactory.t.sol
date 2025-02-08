// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.22;

import "forge-std/Test.sol";
import {AgentBravoDelegate} from "src/AgentBravoDelegate.sol";
import {AgentBravoDelegateFactory} from "src/AgentBravoDelegateFactory.sol";

error OwnableUnauthorizedAccount(address account);

// DummyGovernor will simply return a fixed weight per vote support.
contract DummyGovernor {
    function castVote(uint256, uint8 support) external pure returns (uint256) {
        if (support == 0) return 100;
        if (support == 1) return 200;
        if (support == 2) return 300;
        revert("Invalid support");
    }

    function propose(address[] memory, uint256[] memory, bytes[] memory, string memory)
        external
        pure
        returns (uint256)
    {
        return 1;
    }
}

contract AgentBravoDelegateFactoryTest is Test {
    AgentBravoDelegateFactory public factory;
    AgentBravoDelegate public masterCopy;
    address public owner;
    address public nonOwner;
    address public dummyGovernor;

    function setUp() public {
        owner = address(this);
        nonOwner = address(0xbeef);
        // Deploy a dummy governor which will be used to initialize agents.
        DummyGovernor dummyGov = new DummyGovernor();
        dummyGovernor = address(dummyGov);

        // Deploy the master copy of AgentBravoDelegate.
        masterCopy = new AgentBravoDelegate();
        // Note: We do not call initialize on the master copy; it is used only as an implementation.

        // Deploy the factory with the master copy implementation.
        factory = new AgentBravoDelegateFactory(address(masterCopy));
    }

    function testDeployAgentBravoDelegate() public {
        // Deploy a new AgentBravoDelegate clone via the factory.
        address deployedClone = factory.deployAgentBravoDelegate(dummyGovernor, owner);
        // Check that the clone is stored in the factory.
        uint256 count = factory.getDeployedAgentsCount();
        assertEq(count, 1);
        assertEq(factory.deployedAgents(0), deployedClone);

        // Interact with the clone to ensure it has been initialized.
        AgentBravoDelegate agent = AgentBravoDelegate(deployedClone);
        // Check that the governor is set correctly.
        assertEq(address(agent.governor()), dummyGovernor);
    }

    function testMultipleDeploymentsAndEnumeration() public {
        // Deploy several clones.
        uint256 deployments = 3;
        for (uint256 i = 0; i < deployments; i++) {
            address cloneAddr = factory.deployAgentBravoDelegate(dummyGovernor, owner);
            // Check that each clone is non-zero.
            assertTrue(cloneAddr != address(0));
        }
        uint256 count = factory.getDeployedAgentsCount();
        assertEq(count, deployments);
        // Fetch each clone (this also uses the public deployedAgents getter).
        for (uint256 i = 0; i < count; i++) {
            address cloneAddr = factory.deployedAgents(i);
            assertTrue(cloneAddr != address(0));
        }
    }

    function testUpdateImplementation() public {
        // Deploy a new master copy (implementation) that will be used for future clones.
        AgentBravoDelegate newMaster = new AgentBravoDelegate();
        address newImpl = address(newMaster);
        // As the owner, update the implementation.
        factory.updateImplementation(newImpl);
        // Verify that the implementation was updated.
        assertEq(factory.implementation(), newImpl);
    }

    function testUpdateImplementationRevertForNonOwner() public {
        AgentBravoDelegate newMaster = new AgentBravoDelegate();
        address newImpl = address(newMaster);
        vm.prank(nonOwner);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, nonOwner));
        factory.updateImplementation(newImpl);
    }
}
