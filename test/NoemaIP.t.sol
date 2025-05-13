// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/NoemaIP.sol";

contract NoemaIPTest is Test {
    NoemaIP public noemaIP;
    address public creator;
    address public licensee;
    uint256 public constant LICENSE_FEE = 1 ether;

    function setUp() public {
        creator = makeAddr("creator");
        licensee = makeAddr("licensee");
        vm.deal(creator, 10 ether);
        vm.deal(licensee, 10 ether);
        
        vm.startPrank(creator);
        noemaIP = new NoemaIP();
        vm.stopPrank();
    }

    function testCreateIPAsset() public {
        vm.startPrank(creator);
        
        uint256 tokenId = noemaIP.createIPAsset(
            "Test IP",
            "Test Description",
            "Software",
            "ipfs://test",
            LICENSE_FEE,
            "Test License Terms"
        );

        NoemaIP.IPAsset memory asset = noemaIP.getIPAsset(tokenId);
        assertEq(asset.title, "Test IP");
        assertEq(asset.creator, creator);
        assertEq(asset.licenseFee, LICENSE_FEE);
        
        vm.stopPrank();
    }

    function testGrantLicense() public {
        vm.startPrank(creator);
        uint256 tokenId = noemaIP.createIPAsset(
            "Test IP",
            "Test Description",
            "Software",
            "ipfs://test",
            LICENSE_FEE,
            "Test License Terms"
        );
        vm.stopPrank();

        vm.startPrank(licensee);
        vm.expectEmit(true, true, false, true);
        emit LicenseGranted(tokenId, licensee, LICENSE_FEE);
        noemaIP.grantLicense{value: LICENSE_FEE}(tokenId);
        
        NoemaIP.IPAsset memory asset = noemaIP.getIPAsset(tokenId);
        assertTrue(asset.isLicensed);
        
        address[] memory licensees = noemaIP.getLicensees(tokenId);
        assertEq(licensees[0], licensee);
        
        vm.stopPrank();
    }

    function testRevokeLicense() public {
        vm.startPrank(creator);
        uint256 tokenId = noemaIP.createIPAsset(
            "Test IP",
            "Test Description",
            "Software",
            "ipfs://test",
            LICENSE_FEE,
            "Test License Terms"
        );
        vm.stopPrank();

        vm.startPrank(licensee);
        noemaIP.grantLicense{value: LICENSE_FEE}(tokenId);
        vm.stopPrank();

        vm.startPrank(creator);
        vm.expectEmit(true, true, false, true);
        emit LicenseRevoked(tokenId, licensee);
        noemaIP.revokeLicense(tokenId, licensee);
        
        address[] memory licensees = noemaIP.getLicensees(tokenId);
        assertEq(licensees.length, 0);
        
        vm.stopPrank();
    }

    function testFailGrantLicenseInsufficientFee() public {
        vm.startPrank(creator);
        uint256 tokenId = noemaIP.createIPAsset(
            "Test IP",
            "Test Description",
            "Software",
            "ipfs://test",
            LICENSE_FEE,
            "Test License Terms"
        );
        vm.stopPrank();

        vm.startPrank(licensee);
        vm.expectRevert("Insufficient license fee");
        noemaIP.grantLicense{value: LICENSE_FEE - 1}(tokenId);
        vm.stopPrank();
    }

    function testFailRevokeLicenseNotOwner() public {
        vm.startPrank(creator);
        uint256 tokenId = noemaIP.createIPAsset(
            "Test IP",
            "Test Description",
            "Software",
            "ipfs://test",
            LICENSE_FEE,
            "Test License Terms"
        );
        vm.stopPrank();

        vm.startPrank(licensee);
        noemaIP.grantLicense{value: LICENSE_FEE}(tokenId);
        vm.expectRevert("Not the IP owner");
        noemaIP.revokeLicense(tokenId, licensee);
        vm.stopPrank();
    }
} 