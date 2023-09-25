pragma solidity ^0.4.17;

contract Lottery {

address public manager; //Esta variable es definir quien tiene el poder del contrato. 
address[] public players;


function Lottery() public {
    manager = msg.sender;
}

function enter() public payable { //payable indica que cuando alguien llama a esta funcion ha de enviar una cantidad de ether.
    require(msg.value > .01 ether); //Si lo que hay dentro del requiere es true se ejecutara la funcion. Se usa el msg.value porque asi se mira la cantidad de ether de esa transaccion.Hay qye poner la unidad de ether para que sepa que son ether y no weis que es la unidad pequeña del ether.
    players.push(msg.sender); //el msg.sender indica la address de quien ha llamado a esa funcion.
}

function random() private view returns (uint) { // view porque no vamos a modificar ningun valor. 
     return uint(sha3(block.difficulty, now, players)); //Se puede utilziar tambien el keccak256 que es lo miso que sha3. Block.difficulty es una variable a la que siempre se tiene acceso. Para el numero aleatorio se cogera la dificultad, fecha y hora del momento y el listado de jugadores. 
     
}
function pickWinner() public restricted {
    //require(msg.sender == manager); //De esta forma  hacemos que solo el creador del contrato pueda llamar a esta funcion. Esta linia se puede remplazar por un modificador de funcion. Se introduce el modificador restricted.
    
    uint index = random() % players.length; 
    players[index].transfer(this.blance); //0xqe343r443354 La funcion de transfer es para enviar ether a la cuenta del players[index], si entre los parentesis del trnasfer () ponemos 1, se enviara 1 ether a esa cuenta. Con el this.balance estamos indicando que se envia todo el ether que hay en el contrato. El this es una referencia al contrato en cuestion. 
    players = new address[](0); //Esto sirve para vaciar el array de address y que quede limpio. Es decir para crear un nuevo array de players. el (0) es par ahacer que no haya elementos dentro. 
}

modifier restricted() {
    requiere(msg.sender == manager);
    _;
}

funcion getPlayers() public view returns (address[]) {
    return players;
}
}
