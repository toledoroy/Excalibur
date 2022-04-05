//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./ERC1155GUID.sol";
import "../interfaces/IERC1155Roles.sol";


/**
 * @title Sub-Groups with Role NFTs
 * @dev ERC1155 using GUID as Role
 * To Extend Cases & Jutisdictions
 * - Hold Roles
 * - Assign Roles
 * ---- 
 * - [TODO] request + approve 
 * - [TODO] offer + accept
 * 
 * References: 
 *  Fractal DAO Access Control  https://github.com/fractal-framework/fractal-contracts/blob/93bc0e845a382673f3714e7df858e846d0f10b37/contracts/AccessControl.sol
 *  OZ Access Control  https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol
 */
// abstract contract AccessControl is Context, IAccessControl, ERC165 {
// abstract contract ERC1155Roles is IERC1155Roles, ERC165, Context {
abstract contract ERC1155Roles is IERC1155Roles, ERC1155GUID {
    
    //--- Storage

    //--- Modifiers
    modifier roleExists(string memory role) {
        require(_GUIDExists(_stringToBytes32(role)), "INEXISTENT_ROLE");
        _;
    }
    
    /// Validate that account hold one of the role in Array
    modifier onlyRole(string[] calldata roles) {
        bool hasRole;
        for (uint256 i = 0; i < roles.length; ++i) {
            if(roleHas(_msgSender(), roles[i])) hasRole = true;
        }
        require(hasRole, "ROLE:INVALID_PERMISSION");
        _;
    }

    //--- Functions

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC1155Roles).interfaceId || super.supportsInterface(interfaceId);
    }

    //** Role Functions

    /// Check if account is assigned to role
    function roleHas(address account, string memory role) public view override returns (bool) {
        // return ERC1155GUID.GUIDHas(account, _stringToBytes32(role));
        return GUIDHas(account, _stringToBytes32(role));
        // return (balanceOf(account, _roleToId(_stringToBytes32(role))) > 0);
    }

    /// Assign Someone Else to a Role
    function _roleAssign(address account, string memory role) internal roleExists(role) {
        _GUIDAssign(account, _stringToBytes32(role));
        //TODO: Role Assigned Event?
    }


    /// Remove Someone Else from a Role
    function _roleRemove(address account, string memory role) internal roleExists(role) {
        _GUIDRemove(account, _stringToBytes32(role));
        //TODO: Role Removed Event?
    }

    /// Translate Role to Token ID
    function _roleToId(string memory role) internal view roleExists(role) returns(uint256) {
        return _GUIDToId(_stringToBytes32(role));
    }

    /// Translate string Roles to GUID hashes
    function _stringToBytes32(string memory str) internal pure returns (bytes32){
        require(bytes(str).length <= 32, "String is too long. Max 32 chars");
        return keccak256(abi.encode(str));
    }

    /// Create a new Role
    function _roleCreate(string memory role) internal returns (uint256) {
        return _GUIDMake(_stringToBytes32(role));
    }

}