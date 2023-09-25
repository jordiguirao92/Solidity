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
        address seller; 
        uint price; //sumar el 1% de comision.
        uint totalPrice;
        uint drHashComision;
        uint dailypay;
        uint startTime;
        uint finishTime;
        uint onlineTime;
        uint paymentInterval;
        uint latestPaidTime; //cuando se crea el contrato poner este valor a now
        enum State {Created, Signed, Inactive};
        State public state;
        
    }
    
    contractAgreement[] contractagreements; 
    mapping (uint => contractAgreement) public idcontractAgreement;
    
    function createAgreement (uint _hashtokenId, uint _price, uint _finishtime) public {
        require(msg.sender == hashtokenToOwner[_hashtokenId]);
        
        totalPrice = _price * 1.01;
        drHashComision = totalPrice - _price; 


        uint idAgreement = contractagreements.push(contractAgreement(_hashtokenId, 0x0, msg.sender, _price, totalPrice, drHashComision, 0, _finishtime, 1 days, Created)) - 1; //revisar
        
        idcontractAgreement[idAgreement] = contractAgreement(_hashtokenId, 0x0, msg.sender, _price, 0, _finishtime, 1 days, Created);
        
    }
    
    function abortAgreement(uint _idAgreement) public {
        require(msg.sender == idcontractAgreement[_idAgreement].seller);
        require(idcontractAgreement[_idAgreement].state == Created);
        
        idcontractAgreement[_idAgreement].state == Inactive;
        
    }
    
    function confirmAgreement(uint _idAgreement) public payable {
        require(idcontractAgreement[_idAgreement].state == Created);
        require(msg.value == idcontractAgreement[_idAgreement].price);
        
        idcontractAgreement[_idAgreement].buyer = msg.sender;
        idcontractAgreement[_idAgreement].state = Signed;
        idcontractAgreement[_idAgreement].startTime = now;

        drHashPaymentComision(_idAgreement);

    }

    function cancelAgreement(uint _idAgreement) public {

    }


    function statusAgreement(uint _idAgreement) public returns(string state, uint startTime, uint finishTime, uint paymentInterval, uint unPaidTime) {
        require(msg.sender == idcontractAgreement[_idAgreement].seller || idcontractAgreement[_idAgreement].buyer);
         
         state = idcontractAgreement[_idAgreement].state;
         startTime = idcontractAgreement[_idAgreement].startTime;
         finishTime = idcontractAgreement[_idAgreement].finishTime;
         paymentInterval = idcontractAgreement[_idAgreement].paymentInterval;
         unPaidTime = now - idcontractAgreement[_idAgreement].latestPaidTime;


    }


    function drHashPaymentComision(_idAgreement) private {
        address drhash = 0x12343434;
        uint drComision = idcontractAgreement[_idAgreement].drHashComision;

        drhash.transfer(drComision);

    } 


    
    function dailyPayment(uint _idAgreement, uint _onlineTime, uint _actualDay) public { //El onlineTime diario nos lo ha de dar software de mineria.
         //require(msg.sender == idcontractAgreement[_idAgreement].seller || idcontractAgreement[_idAgreement].buyer);
         //require(idcontractAgreement[_idAgreement].state == Created);
         //require(now >= idcontractAgreement[_idAgreement].startTime + 1 days);

      for(uint i = 0; i < idcontractAgreement.length; i++) {
        if(idcontractAgreement[i].state == Created && idcontractAgreement[i].latestPaidTime + idcontractAgreement[i].paymentInterval < now) {

            if(idcontractAgreement[i].onlineTime == 24){
                idcontractAgreement[i].seller.transfer(idcontractAgreement[i].dailyPay);
            }
            else {
                idcontractAgreement[i].seller.transfer(mul(_onlineTime,div(idcontractAgreement[i].dailyPay,24))) //Entrada del parametro _onlinetime???

            }
        
             }
         }



    }
    
    
