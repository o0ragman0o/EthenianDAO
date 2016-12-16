/******************************************************************************\

file:   Authority.sol
ver:    0.0.1-alpha
updated:16-Dec-2016
author: Darryl Morris (o0ragman0o)
email:  o0ragman0o AT gmail.com

This file is part of the Ethenian DAO framework

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.

\******************************************************************************/

pragma solidity ^0.4.0;

//import "Registrar.sol";
//import "EthenianDAO.sol";
//import "Member.sol";


contract Authority
{
	// Basic Permissions
	bytes4 constant IS_MEMBER =                 0x00000001;
	bytes4 constant IS_MATTER =                 0x00000002;
	bytes4 constant CAN_FUND =                  0x00000004;
	bytes4 constant CAN_VOTE =                  0x00000008;
	bytes4 constant CAN_RAISE_MATTER =          0x00000010;
	bytes4 constant CAN_BE_DELEGATE =           0x00000020;
	bytes4 constant CAN_TENDER =                0x00000040;
	
	// Member Admin Permissions
	bytes4 constant CHANGE_MEMBER_PERMISSIONS = 0x00000100;
	bytes4 constant ALLOW_MEMBER =              0x00000200;
	bytes4 constant DECLINE_MEMBER =            0x00000400;
	bytes4 constant REMOVE_MEMBER =             0x00000800;
	bytes4 constant TRANSFER_TAX =              0x00001000;

	// Matter Admin Permissions
	bytes4 constant CHANGE_MATTER_PERMISSIONS = 0x00010000;
	bytes4 constant ALLOW_MATTER =              0x00020000;
	bytes4 constant DECLINE_MATTER =            0x00040000;
	bytes4 constant CLOSE_MATTER =              0x00080000;

	// DAO Admin Permissions
	bytes4 constant ADD_CONTRACT =              0x01000000;
	bytes4 constant CHANGE_CONTRACT =           0x02000000;

    
    // Compound Permissions
    // Standard Member
    bytes4 constant FULL_MEMBER = IS_MEMBER | CAN_VOTE | CAN_FUND | 
        CAN_RAISE_MATTER | CAN_BE_DELEGATE | CAN_TENDER;
        
    // Members Admin
    bytes4 constant MEMBERS_ADMIN = CHANGE_MEMBER_PERMISSIONS | ALLOW_MEMBER |
        DECLINE_MEMBER | REMOVE_MEMBER | TRANSFER_TAX;
        
    // Matters Admin
    bytes4 constant MATTERS_ADMIN = CHANGE_MATTER_PERMISSIONS | ALLOW_MATTER |
        DECLINE_MATTER | CLOSE_MATTER;

    // DAO Admin
    bytes4 constant DAO_ADMIN = ADD_CONTRACT | CHANGE_CONTRACT;
    
    // SUPERUSER
    bytes4 constant SUPER_USER = FULL_MEMBER | MEMBERS_ADMIN | MATTERS_ADMIN;

    address dao;
    mapping (address => bytes4) permissions;

    function validate(address _subject, bytes4 _accessReq)
        public
        constant
        returns (bytes4)
    {
        return _accessReq & permissions[_subject];
    }
      
    function change(address _subject, bytes4 _access)
        public
        returns (bytes4)
    {
        return permissions[_subject] | MEMBERS_ADMIN | MATTERS_ADMIN;
    }
    
}