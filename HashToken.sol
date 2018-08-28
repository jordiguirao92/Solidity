pragma solidity ^0.4.0;

contract CreateHashToken {
    
    struct HashToken {
        address owner; 
        uint hashRate;
        uint price;
        uint duration;
    }
    
    event NewHashtokenCreate(uint hashtokenId, address hashtokenOwnwer, uint hashtokenHash, uint hashtokenPrice, uint hashtokenDuration);
    
    HashToken[] public hashtokens;
    
    mapping(uint => address) public hashtokenToOwner;
    mapping (address => uint) public ownerHashtokenCount;
    
    function createHashtoken (uint _hashrate, uint _price, uint _duration) public {
        
        uint id = hashtokens.push(HashToken(msg.sender, _hashrate, _price, _duration)) - 1;
        hashtokenToOwner[id] = msg.sender;
        ownerHashtokenCount[msg.sender]++; 
        
        NewHashtokenCreate(id, msg.sender, _hashrate, _price, _duration);
    }
}


contract ERC721 {
    
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function transfer(address _to, uint256 _tokenId) public;
  function approve(address _to, uint256 _tokenId) public;
  function takeOwnership(uint256 _tokenId) public;
}


contract HashTokenTransfer is CreateHashToken, ERC721 {
    
    
    modifier onlyOwnerOf(uint _hashtokenId) {
    require(msg.sender == hashtokenToOwner[_hashtokenId]);
	    _;
     }

    mapping (uint => address) hashtokenApprovals;

  function balanceOf(address _owner) public view returns (uint256 _balance) {
    return ownerHashtokenCount[_owner];
    }
  
  function ownerOf(uint256 _hashtokenId) public view returns (address _owner) {
    return  hashtokenToOwner[_tokenId];
   }

  
  function _transfer(address _from, address _to, uint256 _hashtokenId) private {
     ownerHashtokenCount[_to]++;
     ownerHashtokenCount[_from]--;
     hashtokenToOwner[_hashtokenId] = _to;   
     hashtokens[_hashtokenId].owner = _to;

     Transfer(_from, _to, _hashtokenId);
    }

   
  function transfer(address _to, uint256 _hashtokenId) public onlyOwnerOf(_hashtokenIdtokenId) { 
     _transfer(msg.sender, _to, _hashtokenId);
    }

  
  function approve(address _to, uint256 _hashtokenId) public onlyOwnerOf(_hashtokenId) {
     hashtokenApprovals[__hashtokenId] = _to;
     Approval(msg.sender, _to, __hashtokenId);
    }
  function takeOwnership(uint256 _tokenId) public {
      require(hashtokenApprovals[__hashtokenId] == msg.sender);
      address owner = ownerOf(__hashtokenId);
      _transfer(owner, msg.sender, __hashtokenId);
    }

}


contract ContractAgreement is HashTokenTransfer {
    
    struct contractAgreement {
        uint hashtokenId;
        address buyer;
        uint seller; 
        uint price;
        uint startTime;
        uint finishTime;
        enum State {Created, Signed, Inactive};
        State public state;
        
    }
    
    contractAgreement[] contractagreements; 
    mapping (uint => contractAgreement) public idcontractAgreement;
    
    function createAgreement (uint _hashtokenId, uint _price, uint _finishtime) public {
        require(msg.sender == hashtokenToOwner[_hashtokenId]);
        
        uint idAgreement = contractagreements.push(contractAgreement())
        
    }
    
    
    
}




    
