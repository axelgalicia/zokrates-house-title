// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "./ERC721Enumerable.sol";

contract ERC721Metadata is ERC721Enumerable {
    // TODO: Create private vars for token _name, _symbol, and _baseTokenURI (string)
    string private _name;
    string private _symbol;
    string private _baseTokenURI;

    // TODO: create private mapping of tokenId's to token uri's called '_tokenURIs'
    mapping (uint256 => string) private _tokenURIs;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    /*
     * 0x5b5e139f ===
     *     bytes4(keccak256('name()')) ^
     *     bytes4(keccak256('symbol()')) ^
     *     bytes4(keccak256('tokenURI(uint256)'))
     */

    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI
    ) public {
        // TODO: set instance var values
        _name = name;
        _symbol = symbol;
        _baseTokenURI = baseTokenURI;
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId));
        return _tokenURIs[tokenId];
    }

    function getName() external view returns(string memory) {
        return _name;
    }

    function getSymbol() external view returns(string memory) {
        return _symbol;
    }

    function getBaseTokenURI() external view returns(string memory) {
        return _baseTokenURI;
    }

    function setTokenURI(uint256 tokenId) internal {
        require(_exists(tokenId), "The tokenId does not exist");
        _tokenURIs[tokenId] = strConcat(_baseTokenURI, uint2str(tokenId));
    }

    function strConcat(string memory _a, string memory _b) internal pure returns (string memory _concatenatedString) {
        return strConcat(_a, _b, "", "", "");
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes32(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}