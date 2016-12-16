/******************************************************************************\

file:   BidirectionalLUT.sol
ver:    0.0.1
updated:8-Dec-2016
author: Darryl Morris (o0ragman0o)
email:  o0ragman0o AT gmail.com

A generic bidirectional Look Up Table (LUT). Proving an element will return
it's index. Providing an index will return it's element.

Maximum index value must be less than minium element value. 


This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.

\******************************************************************************/

pragma solidity ^0.4.0;


contract BidirectionalLUT
{
    // element at index 0 has implicit value of 0 so start index at 1
    uint public size = 1; 

    // easier to cast address and bytes32 to uint
    mapping (bytes32 => uint) lut;

    function exists(uint _indexOrElement)
        public
        constant
        returns (bool)
    {
        return lut[sha3(_indexOrElement)] != 0;
    }
    
    function addIntl(uint _element)
        internal
        returns (uint)
    {
        lut[sha3(_element)] = size;
        lut[sha3(size)] = _element;
        size++;
        return size;
    }
    
    function removeIntl(uint _indexOrElement)
        internal
        returns (bool)
    {
        uint elementOrIndex = lut[sha3(_indexOrElement)];
        delete lut[sha3(_indexOrElement)];
        delete lut[sha3(elementOrIndex)];
        size--;
        return true;
    }
    
    function getIntl(uint _indexOrElement)
        constant
        returns (uint)
    {
        return lut[sha3(_indexOrElement)];
    }
}
