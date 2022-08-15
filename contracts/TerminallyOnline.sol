// SPDX-License-Identifier: MIT

import "./Dependencies.sol";

pragma solidity ^0.8.11;

interface ITokenURI {
  function tokenURI(uint256 tokenId) external view returns (string memory);
}

contract TerminallyOnline is ERC721, Ownable {
  ITokenURI public tokenURIContract;

  address public multisig;

  address private royaltyBenificiary;
  uint16 private royaltyBasisPoints = 1000;
  string public license = 'CC BY-NC 4.0';

  uint256 private tokenCount;

  event ProjectEvent(address indexed poster, string indexed eventType, string content);
  event TokenEvent(address indexed poster, uint256 indexed tokenId, string indexed eventType, string content);

  constructor() ERC721("Terminally Online", 'ONLINE') {
    multisig = msg.sender;
    royaltyBenificiary = msg.sender;
  }

  modifier onlyMultisig() {
    require(multisig == _msgSender(), 'Caller is not the multisig address');
    _;
  }

  // Base functionality
  function totalSupply() external view returns (uint256) {
    return tokenCount;
  }

  function exists(uint256 tokenId) external view returns (bool) {
    return _exists(tokenId);
  }

  function mint(address to, uint256 tokenId) external onlyOwner {
    _mint(to, tokenId);
    tokenCount++;
  }

  // Multisig update
  function setMultisigContract(address newAddress) external onlyMultisig {
    multisig = newAddress;
  }


  // Events
  function emitTokenEvent(uint256 tokenId, string calldata eventType, string calldata content) external {
    require(
      owner() == _msgSender() || ERC721.ownerOf(tokenId) == _msgSender(),
      'Only project or token owner can emit token event'
    );
    emit TokenEvent(_msgSender(), tokenId, eventType, content);
  }

  function emitProjectEvent(string calldata eventType, string calldata content) external onlyMultisig {
    emit ProjectEvent(_msgSender(), eventType, content);
  }


  // Token URI
  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    return tokenURIContract.tokenURI(tokenId);
  }

  function setTokenURIContract(address _tokenURIAddress) external onlyMultisig {
    tokenURIContract = ITokenURI(_tokenURIAddress);
  }


  // Contract owner actions
  function updateLicense(string calldata newLicense) external onlyOwner {
    license = newLicense;
  }

  // Royalty Info
  function setRoyaltyInfo(
    address _royaltyBenificiary,
    uint16 _royaltyBasisPoints
  ) external onlyOwner {
    royaltyBenificiary = _royaltyBenificiary;
    royaltyBasisPoints = _royaltyBasisPoints;
  }

  function royaltyInfo(uint256, uint256 _salePrice) external view returns (address, uint256) {
    return (royaltyBenificiary, _salePrice * royaltyBasisPoints / 10000);
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721) returns (bool) {
    // 0x2a55205a == ERC2981 interface id
    return interfaceId == 0x2a55205a || super.supportsInterface(interfaceId);
  }
}

