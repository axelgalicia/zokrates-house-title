// SPDX-License-Identifier: LGPL-3.0-only
// This file is LGPL3 Licensed
pragma solidity 0.8.1;

import "./openzeppelin/ERC721Metadata.sol";

contract ERC721MintableCustom is ERC721Metadata {
    //  1) Pass in appropriate values for the inherited ERC721Metadata contract
    //  - make the base token uri: https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/
    constructor(string memory name, string memory symbol)
        ERC721Metadata(
            name,
            symbol,
            "https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/"
        )
    {}

    //  2) create a public mint() that does the following:
    //  -can only be executed by the contract owner
    //  -takes in a 'to' address, tokenId as parameters
    //  -returns a true boolean upon completion of the function
    //  -calls the superclass mint and setTokenURI functions
    function mint(address to, uint256 tokenId)
        public
        onlyOwner
        whenNotPaused
        returns (bool)
    {
        super._mint(to, tokenId);
        setTokenURI(tokenId);
        return true;
    }
}
