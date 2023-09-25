pragma solidity >=0.4.22 <0.7.0;

contract Object {

    string public name;
    address payable public owner;
    
    
    constructor (string memory _name, address payable _owner) public {
        name = _name;
        owner = _owner;
    }
}



contract ObjectFactory {
    
    address payable public owner;
    
    constructor () public {
        owner = msg.sender;
    }
    
    
    function createObject(string memory name) public returns (address objectAddress) {
        return address(new Object(name, owner));
    }
}
