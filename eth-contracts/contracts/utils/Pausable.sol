// SPDX-License-Identifier: LGPL-3.0-only
// This file is LGPL3 Licensed
pragma solidity 0.8.1;

import "./Ownable.sol";

contract Pausable is Ownable {
    bool private _paused;

    event Paused(address indexed account);
    event Unpaused(address indexed account);

    modifier whenNotPaused() {
        require(_paused == false, "Contract needs to be unpaused");
        _;
    }

    modifier paused() {
        require(_paused == true, "Contract needs to be paused");
        _;
    }

    function pause(bool newState) public onlyOwner {
        _paused = newState;
        emit Paused(msg.sender);
    }

    function unpause() public onlyOwner paused {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    constructor() {
        _paused = false;
    }
}
