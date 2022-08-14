
contract ThisWontLastURI {
  struct TokenData {
    string name;
    string description;
    string uri;
    string thumbnail;
  };

  TokenData[12] public tokens;

  address public owner;
  string public externalUrl = '';

  constructor() {
    owner = msg.sender;

    tokens[0].name = 'time';
    tokens[0].description = 'TIME IS RUNNING OUT: ACT NOW';
    tokens[0].uri = 'ipfs://...';
    tokens[0].thumbnail = 'ipfs://...';

    tokens[1].name = 'money';
    tokens[1].description = 'Stop Throwing Your Money Away';
    tokens[1].uri = 'ipfs://...';
    tokens[1].thumbnail = 'ipfs://...';

    tokens[2].name = 'life';
    tokens[2].description = 'Is Something Missing From Your Life?';
    tokens[2].uri = 'ipfs://...';
    tokens[2].thumbnail = 'ipfs://...';

    tokens[3].name = 'death';
    tokens[3].description = 'Your Death Is Coming! Are YOU prepared to die?';
    tokens[3].uri = 'ipfs://...';
    tokens[3].thumbnail = 'ipfs://...';

    tokens[4].name = 'fomo';
    tokens[4].description = 'Fear Of Missing Out';
    tokens[4].uri = 'ipfs://...';
    tokens[4].thumbnail = 'ipfs://...';

    tokens[5].name = 'fear';
    tokens[5].description = 'FEAR UNCERTAINTY DOUBT';
    tokens[5].uri = 'ipfs://...';
    tokens[5].thumbnail = 'ipfs://...';

    tokens[6].name = 'uncertainty';
    tokens[6].description = 'FEAR UNCERTAINTY DOUBT;
    tokens[6].uri = 'ipfs://...';
    tokens[6].thumbnail = 'ipfs://...';

    tokens[7].name = 'doubt';
    tokens[7].description = 'Fear Uncertainty Doubt';
    tokens[7].uri = 'ipfs://...';
    tokens[7].thumbnail = 'ipfs://...';

    tokens[8].name = 'god';
    tokens[8].description = 'Disclaimer';
    tokens[8].uri = 'ipfs://...';
    tokens[8].thumbnail = 'ipfs://...';

    tokens[9].name = 'hell';
    tokens[9].description = 'Are you going to HELL?';
    tokens[9].uri = 'ipfs://...';
    tokens[9].thumbnail = 'ipfs://...';

    tokens[10].name = 'stop';
    tokens[10].description = 'STOP! Unless you understand exactly what you are doing';
    tokens[10].uri = 'ipfs://...';
    tokens[10].thumbnail = 'ipfs://...';

    tokens[11].name = 'yes';
    tokens[11].description = 'Is this all there is? Yes!';
    tokens[11].uri = 'ipfs://...';
    tokens[11].thumbnail = 'ipfs://...';
  }

  modifier onlyOwner() {
    require(owner == msg.sender, "Caller is not the owner");
    _;
  }

  function transferOwnership(address newOwner) external onlyOwner {
    owner = newOwner
  }

  function updateExternalUrl(string calldata _externalUrl) external onlyOwner {
    externalUrl = _externalUrl;
  }

  function tokenURI(uint256 tokenId) public view returns (string memory) {
    string memory name = tokens[tokenId].name;
    string memory description = tokens[tokenId].description;
    string memory uri = tokens[tokenId].uri;
    string memory thumbnail = tokens[tokenId].thumbnail;
    string memory externalUrl = string(abi.encodePacked(name, '.', baseExternalUrl));

    string memory json = Base64.encode(
      abi.encodePacked(
        '{"name": "', name,
        '", "description": "', description,
        '", "animation_url": "', uri,
        '", "image": "', thumbnail,
        '", "external_url": "', externalUrl,
        '"}'
      )
    );

    return string(abi.encodePacked('data:application/json;base64,', json));
  }
}


/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}
