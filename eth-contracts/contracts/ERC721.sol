// SPDX-License-Identifier: LGPL-3.0-only
// This file is LGPL3 Licensed
pragma solidity 0.8.1;

import "./openzeppelin/Address.sol";
import "./openzeppelin/Counters.sol";
import "./openzeppelin/SafeMath.sol";
import "./openzeppelin/ERC165.sol";
import "./openzeppelin/IERC721Receiver.sol";

import "./utils/Ownable.sol";
import "./utils/Pausable.sol";


contract ERC721 is Pausable, ERC165 {

    using SafeMath for uint256;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from token ID to owner
    mapping(uint256 => address) private _tokenOwner;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to number of owned token
    // IMPORTANT: this mapping uses Counters lib which is used to protect overflow when incrementing/decrementing a uint
    // use the following functions when interacting with Counters: increment(), decrement(), and current() to get the value
    // see: https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/drafts/Counters.sol
    mapping(address => Counters.Counter) private _ownedTokensCount;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    constructor() {
        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    function balanceOf(address owner) public view returns (uint256) {
        // TODO return the token balance of given address
          return _ownedTokensCount[owner].current();
        // TIP: remember the functions to use for Counters. you can refresh yourself with the link above
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        // TODO return the owner of the given tokenId
        return _tokenOwner[tokenId];
    }

    //    @dev Approves another address to transfer the given token ID
    function approve(address to, uint256 tokenId) public {
        address tokenOwner = ownerOf(tokenId);
        // TODO require the given address to not be the owner of the tokenId
        require(to != tokenOwner, "Cannot approve to yourself");
        // TODO require the msg sender to be the owner of the token or isApprovedForAll() to be true
        require(msg.sender == tokenOwner || isApprovedForAll(tokenOwner, msg.sender), "Caller is not authorized against this token");
        // TODO add 'to' address to token approvals
        _tokenApprovals[tokenId] = to;
        // TODO emit Approval Event
        emit Approval(tokenOwner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        // TODO return token approval if it exists
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev Sets or unsets the approval of a given operator
     * An operator is allowed to transfer all tokens of the sender on their behalf
     * @param to operator address to set the approval
     * @param approved representing the status of the approval to be set
     */
    function setApprovalForAll(address to, bool approved) public {
        require(to != msg.sender);
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    /**
     * @dev Tells whether an operator is approved by a given owner
     * @param owner owner address which you want to query the approval of
     * @param operator operator address which you want to query the approval of
     * @return bool whether the given operator is approved by the given owner
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not Approved to transfer Token");

        _transferFromInternal(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data));
    }

    /**
     * @dev Returns whether the specified token exists
     * @param tokenId uint256 ID of the token to query the existence of
     * @return bool whether the token exists
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    /**
     * @dev Returns whether the given spender can transfer a given token ID
     * @param spender address of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     * is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        returns (bool)
    {
        address owner = ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    // @dev Internal function to mint a new token
    // TIP: remember the functions to use for Counters. you can refresh yourself with the link above
    function _mintInternal(address to, uint256 tokenId) internal {
        // TODO revert if given tokenId already exists or given address is invalid
        require(_tokenOwner[tokenId] == address(0), "Token exists already");
        require(to != address(0), "Invalid to address");
        // TODO mint tokenId to given address & increase token count of owner
        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();
        // TODO emit Transfer event
        emit Transfer(address(0), to, tokenId);
    }

    // @dev Internal function to transfer ownership of a given token ID to another address.
    // TIP: remember the functions to use for Counters. you can refresh yourself with the link above
    function _transferFromInternal(
        address from,
        address to,
        uint256 tokenId
    ) internal {
         // TODO: require from address is the owner of the given token
        require(from == ownerOf(tokenId), "Only token owner can perform this");
        // TODO: require token is being transfered to valid address
        require(to != address(0), "Invalid to address");
        // TODO: clear approval
        _clearApproval(tokenId);
        // TODO: update token counts & transfer ownership of the token ID 
        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();
        _tokenOwner[tokenId] = to;
        // TODO: emit correct event
        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Internal function to invoke `onERC721Received` on a target address
     * The call is not executed if the target address is not a contract
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal returns (bool) {
        if (!to.isContract()) {
            return true;
        }

        bytes4 retval =
            IERC721Receiver(to).onERC721Received(
                msg.sender,
                from,
                tokenId,
                _data
            );
        return (retval == _ERC721_RECEIVED);
    }

    // @dev Private function to clear current approval of a given token ID
    function _clearApproval(uint256 tokenId) private {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}