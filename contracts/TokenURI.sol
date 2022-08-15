// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface ITerminallyOnline {
  function multisig() external view returns (address);
}

contract TokenURI {
  struct TokenData {
    string name;
    string description;
    string uri;
    string thumbnail;
  }

  TokenData[12] public tokens;

  address public baseAddress;
  string public externalUrl = 'terminallyonline.eth.link';
  string public baseURI = 'ipfs://bafybeige5hd3wp3ewrj5pp4u4cmfuiasxxhprrszcwdglzt3vhzqhgcm4u';

  constructor(address _baseAddress) {
    baseAddress = _baseAddress;

    tokens[0].name = 'time';
    tokens[0].description = 'TIME IS RUNNING OUT: ACT NOW';
    tokens[0].uri = 'ipfs://bafkreidpvlppqosimrvvvy5ye7wqnuu2doa3sjw3fsek2nuoii5gnjllbe';

    tokens[1].name = 'money';
    tokens[1].description = 'Stop Throwing Your Money Away';
    tokens[1].uri = 'ipfs://bafkreiempqhdgkgzibebptqqgcxktiw6mkxjb3kls35dhyg256z34mry4e';

    tokens[2].name = 'life';
    tokens[2].description = 'Is Something Missing From Your Life?';
    tokens[2].uri = 'ipfs://bafkreia4ogroqa7msvibwkxoot5ztsnq372dvr3dqiles6orvnj4hdgnbq';

    tokens[3].name = 'death';
    tokens[3].description = 'Your Death Is Coming! Are YOU prepared to die?';
    tokens[3].uri = 'ipfs://bafkreidiylknzobfn3hkslw2rpm72t4vd7ksqrnwktl6rkkd3ikxyu4ofu';

    tokens[4].name = 'fomo';
    tokens[4].description = 'FOMO';
    tokens[4].uri = 'ipfs://bafkreiaavsguqgj235rc6orqk2bk6myqbx64mpmygrn2hipotovn22zcw4';

    tokens[5].name = 'fear';
    tokens[5].description = 'FEAR UNCERTAINTY DOUBT';
    tokens[5].uri = 'ipfs://bafkreibfg7ibh6xtdeuk7ikswvd6po2zvwizoblnigskwtr7w3ecc37psm';

    tokens[6].name = 'uncertainty';
    tokens[6].description = 'FEAR UNCERTAINTY DOUBT';
    tokens[6].uri = 'ipfs://bafkreibp6stctm5iuxqnpni3nxiaekkxvvs2l4cxpnqpg2joadobo7qh4i';

    tokens[7].name = 'doubt';
    tokens[7].description = 'Fear Uncertainty Doubt';
    tokens[7].uri = 'ipfs://bafkreie777mazoeotypfnczgjkvilmgmamg3im7wef6ez4xqhkopyxkxla';

    tokens[8].name = 'god';
    tokens[8].description = 'Disclaimer';
    tokens[8].uri = 'ipfs://bafkreiaob4jy6zl62bpmuv3nv7oxjv2phwtbwxzrughplbhssg3q4phoxu';

    tokens[9].name = 'hell';
    tokens[9].description = 'Are you going to HELL?';
    tokens[9].uri = 'ipfs://bafkreigqnziyeuczo4n73zpshlobzk2gvh5267ebvdvdcjlu6vtptjgbja';

    tokens[10].name = 'stop';
    tokens[10].description = 'STOP! Unless you understand exactly what you are doing';
    tokens[10].uri = 'ipfs://bafkreibxf6te63sfuvnu3zrji64iitp3txycvazv2wub57ramvquohhqjm';

    tokens[11].name = 'yes';
    tokens[11].description = 'Is this all there is? Yes!';
    tokens[11].uri = 'ipfs://bafkreiadu556ki44k2tihpho5jrpcppxzw7nhskoznhq6deo73ntohtbjq';
  }

  modifier onlyOwner() {
    require(ITerminallyOnline(baseAddress).multisig() == msg.sender, "Caller is not the URI owner");
    _;
  }


  function updateExternalUrl(string calldata _externalUrl) external onlyOwner {
    externalUrl = _externalUrl;
  }

  function tokenURI(uint256 tokenId) public view returns (string memory) {
    string memory name = tokens[tokenId].name;
    string memory description = tokens[tokenId].description;
    string memory uri = tokens[tokenId].uri;
    string memory thumbnail = string(abi.encodePacked(baseURI, '/', name, '.png'));
    string memory tokenExternalUrl = string(abi.encodePacked(name, '.', externalUrl));

    string memory json = Base64.encode(
      abi.encodePacked(
        '{"name": "', name,
        '", "description": "', description,
        '", "animation_url": "', uri,
        '", "image": "', thumbnail,
        '", "external_url": "', tokenExternalUrl,
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
