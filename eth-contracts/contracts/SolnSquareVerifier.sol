// SPDX-License-Identifier: LGPL-3.0-only
// This file is LGPL3 Licensed
pragma solidity ^0.8.1;

import "./ERC721MintableComplete.sol";
import "./Verifier.sol";

// TODO define another contract named SolnSquareVerifier that inherits from your ERC721Mintable class
contract SolnSquareVerifier is ERC721MintableComplete {
    // TODO define a contract call to the zokrates generated solidity contract <Verifier> or <renamedVerifier>
    Verifier private verifierContract;

    constructor(
        address verifierAddress,
        string memory name,
        string memory symbol
    ) ERC721MintableComplete(name, symbol) {
        verifierContract = Verifier(verifierAddress);
    }

    // TODO define a solutions struct that can hold an index & an address
    struct Solution {
        uint256 solutionIndex;
        address solutionAddress;
        bool minted; //flag to indicate if this solution has been used in token minting
    }

    // TODO define an array of the above struct
    // Solution[] private solutions;
    uint256 numberOfSolutions = 0;

    // TODO define a mapping to store unique solutions submitted
    mapping(bytes32 => Solution) solutions;

    // TODO Create an event to emit when a solution is added
    event SolutionAdded(uint256 solutionIndex, address indexed solutionAddress);

    // TODO Create a function to add the solutions to the array and emit the event
    function addSolution(
        uint256[2] memory A,
        uint256[2][2] memory B,
        uint256[2] memory C,
        uint256[2] memory input
    ) public {
        bytes32 solutionHash = keccak256(abi.encodePacked(input[0], input[1]));
        require(
            solutions[solutionHash].solutionAddress == address(0),
            "Solution exists already"
        );

        bool verified = verifierContract.verifyTx(A, B, C, input);
        require(verified, "Solution could not be verified");

        solutions[solutionHash] = Solution(
            numberOfSolutions,
            msg.sender,
            false
        );
        //solutions.push(solution);
        emit SolutionAdded(numberOfSolutions, msg.sender);
        numberOfSolutions++;
    }

    // TODO Create a function to mint new NFT only after the solution has been verified
    //  - make sure the solution is unique (has not been used before)
    //  - make sure you handle metadata as well as tokenSuplly
    function mintNewNFT(
        uint256 a,
        uint256 b,
        address to
    ) public {
        bytes32 solutionHash = keccak256(abi.encodePacked(a, b));
        require(
            solutions[solutionHash].solutionAddress != address(0),
            "Solution does not exist"
        );
        require(
            solutions[solutionHash].minted == false,
            "Token already minted for this solution"
        );
        require(
            solutions[solutionHash].solutionAddress == msg.sender,
            "Only solution address can use it to mint a token"
        );
        super.mint(to, solutions[solutionHash].solutionIndex);
        solutions[solutionHash].minted = true;
    }
}
