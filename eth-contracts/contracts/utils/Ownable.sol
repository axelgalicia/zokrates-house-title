// SPDX-License-Identifier: LGPL-3.0-only
// This file is LGPL3 Licensed
pragma solidity 0.8.1;

contract Ownable {
    address payable private _owner;

    event OwnershipTransfered(
        address indexed previousOwner,
        address indexed newOwner
    );

    modifier onlyOwner() {
        require(
            msg.sender == _owner,
            "Only contract's owner can call this function"
        );
        _;
    }

    constructor() {
        _owner = payable(msg.sender);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        // TODO add functionality to transfer control of the contract to a newOwner.
        // make sure the new owner is a real address
        require(newOwner != address(0), "Not a valid address");
        emit OwnershipTransfered(_owner, newOwner);
    }

    function getOwner() public pure returns (address) {
        return _owner;
    }
}
