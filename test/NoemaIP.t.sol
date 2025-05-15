// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/NoemaIP.sol";

contract NoemaIPTest is Test {
    NoemaIP public noemaIP;
    address public creator;
    address public licensee;
    uint256 public constant LICENSE_FEE = 1 ether;

    // Event declarations for testing
    event LicenseGranted(uint256 indexed tokenId, address indexed licensee, uint256 fee);
    event LicenseRevoked(uint256 indexed tokenId, address indexed licensee);

    function setUp() public {
        creator = makeAddr("creator");
        licensee = makeAddr("licensee");
        vm.deal(creator, 10 ether);
        vm.deal(licensee, 10 ether);
        
        vm.startPrank(creator);
        noemaIP = new NoemaIP();
        vm.stopPrank();
    }

    function test_CreateIPAsset() public {
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
        assertEq(asset.description, "Test Description");
        assertEq(asset.category, "Software");
        assertEq(asset.creator, creator);
        assertEq(asset.isLicensed, false);
        assertEq(asset.licenseFee, LICENSE_FEE);
        assertEq(asset.licenseTerms, "Test License Terms");
        assertEq(noemaIP.ownerOf(tokenId), creator);

        vm.stopPrank();
    }

    function test_GrantLicense() public {
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
        vm.expectEmit(true, true, true, true);
        emit LicenseGranted(tokenId, licensee, LICENSE_FEE);
        noemaIP.grantLicense{value: LICENSE_FEE}(tokenId);

        NoemaIP.IPAsset memory asset = noemaIP.getIPAsset(tokenId);
        assertEq(asset.isLicensed, true);

        address[] memory licensees = noemaIP.getLicensees(tokenId);
        assertEq(licensees.length, 1);
        assertEq(licensees[0], licensee);
        vm.stopPrank();
    }

    function test_RevokeLicense() public {
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
        vm.expectEmit(true, true, true, true);
        emit LicenseRevoked(tokenId, licensee);
        noemaIP.revokeLicense(tokenId, licensee);

        address[] memory licensees = noemaIP.getLicensees(tokenId);
        assertEq(licensees.length, 0);
        vm.stopPrank();
    }

    function testFail_GrantLicenseInsufficientFee() public {
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
        noemaIP.grantLicense{value: LICENSE_FEE - 1}(tokenId);
        vm.stopPrank();
    }

    function testFail_GrantLicenseToSelf() public {
        vm.startPrank(creator);
        uint256 tokenId = noemaIP.createIPAsset(
            "Test IP",
            "Test Description",
            "Software",
            "ipfs://test",
            LICENSE_FEE,
            "Test License Terms"
        );
        noemaIP.grantLicense{value: LICENSE_FEE}(tokenId);
        vm.stopPrank();
    }

    function testFail_RevokeLicenseNotOwner() public {
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
        noemaIP.revokeLicense(tokenId, licensee);
        vm.stopPrank();
    }

    function test_GetCreatorAssets() public {
        vm.startPrank(creator);
        uint256 tokenId1 = noemaIP.createIPAsset(
            "Test IP 1",
            "Test Description 1",
            "Software",
            "ipfs://test1",
            LICENSE_FEE,
            "Test License Terms 1"
        );
        uint256 tokenId2 = noemaIP.createIPAsset(
            "Test IP 2",
            "Test Description 2",
            "Software",
            "ipfs://test2",
            LICENSE_FEE,
            "Test License Terms 2"
        );
        vm.stopPrank();

        uint256[] memory assets = noemaIP.getCreatorAssets(creator);
        assertEq(assets.length, 2);
        assertEq(assets[0], tokenId1);
        assertEq(assets[1], tokenId2);
    }
} 