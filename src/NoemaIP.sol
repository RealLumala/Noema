// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NoemaIP is ERC721URIStorage, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct IPAsset {
        string title;
        string description;
        string category;
        address creator;
        uint256 creationDate;
        bool isLicensed;
        uint256 licenseFee;
        string licenseTerms;
    }

    mapping(uint256 => IPAsset) public ipAssets;
    mapping(address => uint256[]) public creatorAssets;
    mapping(uint256 => address[]) public licensees;

    event IPAssetCreated(uint256 indexed tokenId, address indexed creator, string title);
    event LicenseGranted(uint256 indexed tokenId, address indexed licensee, uint256 fee);
    event LicenseRevoked(uint256 indexed tokenId, address indexed licensee);

    constructor() ERC721("NoemaIP", "NOEMA") {}

    function createIPAsset(
        string memory title,
        string memory description,
        string memory category,
        string memory tokenURI,
        uint256 licenseFee,
        string memory licenseTerms
    ) public nonReentrant returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        ipAssets[newTokenId] = IPAsset({
            title: title,
            description: description,
            category: category,
            creator: msg.sender,
            creationDate: block.timestamp,
            isLicensed: false,
            licenseFee: licenseFee,
            licenseTerms: licenseTerms
        });

        creatorAssets[msg.sender].push(newTokenId);

        emit IPAssetCreated(newTokenId, msg.sender, title);
        return newTokenId;
    }

    function grantLicense(uint256 tokenId) public payable nonReentrant {
        require(_exists(tokenId), "IP asset does not exist");
        require(msg.value >= ipAssets[tokenId].licenseFee, "Insufficient license fee");
        
        address creator = ownerOf(tokenId);
        require(creator != msg.sender, "Cannot license your own IP");
        
        licensees[tokenId].push(msg.sender);
        ipAssets[tokenId].isLicensed = true;
        
        (bool success, ) = creator.call{value: msg.value}("");
        require(success, "Transfer failed");

        emit LicenseGranted(tokenId, msg.sender, msg.value);
    }

    function revokeLicense(uint256 tokenId, address licensee) public {
        require(_exists(tokenId), "IP asset does not exist");
        require(ownerOf(tokenId) == msg.sender, "Not the IP owner");
        
        address[] storage currentLicensees = licensees[tokenId];
        for (uint i = 0; i < currentLicensees.length; i++) {
            if (currentLicensees[i] == licensee) {
                currentLicensees[i] = currentLicensees[currentLicensees.length - 1];
                currentLicensees.pop();
                break;
            }
        }
        
        emit LicenseRevoked(tokenId, licensee);
    }

    function getIPAsset(uint256 tokenId) public view returns (IPAsset memory) {
        require(_exists(tokenId), "IP asset does not exist");
        return ipAssets[tokenId];
    }

    function getCreatorAssets(address creator) public view returns (uint256[] memory) {
        return creatorAssets[creator];
    }

    function getLicensees(uint256 tokenId) public view returns (address[] memory) {
        require(_exists(tokenId), "IP asset does not exist");
        return licensees[tokenId];
    }
}