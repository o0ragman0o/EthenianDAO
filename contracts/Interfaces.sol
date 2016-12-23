/******************************************************************************\

file:   Interfaces.sol
ver:    0.0.3-alpha
updated:23-Dec-2016
author: Darryl Morris (o0ragman0o)
email:  o0ragman0o AT gmail.com



This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.

\******************************************************************************/

pragma solidity ^0.4.0;


contract DAOAccountInterface
{
    EthenianDAOInterface public dao;
    uint public lastActiveBlock;
    uint public lastActiveBalance;
    uint public fundedCredits;
    bytes8 public permissions;
    function changePermissions(bytes8 _permissions) external returns (bool);
    function fundMatter(uint _matterId, uint _amount) external returns (bool);
}


contract MatterInterface
{
    string constant public VERSION = "Matter 0.0.3-alpha";
    bool constant CLOSED = false;
    bool constant OPEN = true;
    
    struct Option {
        // voter -> tokens -> voting power
        bool open;
        uint value;
        uint votes;
        bytes32 name;
        address recipient;
    }
    
    bool public open;
    bool public recurrent;
//    bool public tendering;
//    bool public funding;
//    bool public refunding;
    uint public matterId;
    uint public numOptions;
    uint public votesCast;
    uint public openTimeStamp;
    uint public period;
    uint public periods;
    bytes32 public name;
    mapping (uint => Option) public options;
    // voter -> optionId -> votes
    mapping (address => mapping (uint => uint)) public voters;

    function value() public constant returns (uint);
    function average() public constant returns (uint);
    function leader() public constant returns (uint);
    function vote(uint _optionId, uint _votes) external returns (bool);
    function addOption(bytes32 _name, uint _value, address _recipient) 
        external returns (uint);
    function fund(uint _amount) payable returns (bool);
}

contract AuthorityInterface
{
    EthenianDAOInterface dao;
    mapping (address => bytes4) permissions;
    function validate(address _subject, bytes4 _accessReq) 
        public constant returns (bytes4);
    function change(address _subject, bytes4 _access)
        public returns (bytes4);
}

contract EthenianDAOInterface
{
    function attritionTaxRate() public constant returns (uint aTR_);
    function withdrawalTaxRate() public constant returns (uint wTR_);
    function minimumVoteBalance() public constant returns (uint minVB_);
    function maximumVoteBalance() public constant returns (uint maxVB_);
    function authority() public constant returns (address auth_);
    function getMember(bytes32 _name) public constant returns (address member_);
    function getMatter(bytes32 _name) public constant returns (address matter_);
    function setContract(bytes32 _name, address _addr) public returns (bool);
    function newMember(bytes32 _name, string _url) public returns (address member_);
    function newMatter(bytes32 _name, string _url) public returns (address matter_);
    function getByName(bytes32 _name) public constant returns (address addr_);
    function getById(uint _id) public constant returns (address addr_);
}

