pragma solidity ^0.4.11;

contract SimpleAuction {
    // Parámetros de la subasta. Los tiempos son
    // o timestamps estilo unix (segundos desde 1970-01-01)
    // o periodos de tiempo en segundos.
    address public beneficiary;
    uint public auctionStart;
    uint public biddingTime;

    // Estado actual de la subasta.
    address public highestBidder;
    uint public highestBid;

    // Retiradas de dinero permitidas de las anteriores pujas
    mapping(address => uint) pendingReturns;

    // Fijado como true al final, no permite ningún cambio.
    bool ended;

    // Eventos que serán emitidos al realizar algún cambio
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    // Lo siguiente es lo que se conoce como un comentario natspec,
    // se identifican por las tres barras inclinadas.
    // Se mostrarán cuando se pregunte al usuario
    // si quiere confirmar la transacción.

    /// Crea una subasta sencilla con un periodo de pujas
    /// de `_biddingTime` segundos. El beneficiario de
    /// las pujas es la dirección `_beneficiary`.
    function SimpleAuction(
        uint _biddingTime,
        address _beneficiary
    ) {
        beneficiary = _beneficiary;
        auctionStart = now;
        biddingTime = _biddingTime;
    }

    /// Puja en la subasta con el valor enviado
    /// en la misma transacción.
    /// El valor pujado sólo será devuelto
    /// si la puja no es ganadora.
    function bid() payable {
        // No hacen falta argumentos, toda
        // la información necesaria es parte de
        // la transacción. La palabra payable
        // es necesaria para que la función pueda recibir Ether.

        // Revierte la llamada si el periodo
        // de pujas ha finalizado.
        require(now <= (auctionStart + biddingTime));

        // Si la puja no es la más alta,
        // envía el dinero de vuelta.
        require(msg.value > highestBid);

        if (highestBidder != 0) {
            // Devolver el dinero usando
            // highestBidder.send(highestBid) es un riesgo
            // de seguridad, porque la llamada puede ser evitada
            // por el usuario elevando la pila de llamadas a 1023.
            // Siempre es más seguro dejar que los receptores
            // saquen su propio dinero.
            pendingReturns[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        HighestBidIncreased(msg.sender, msg.value);
    }

    /// Retira una puja que fue superada.
    function withdraw() returns (bool) {
        var amount = pendingReturns[msg.sender];
        if (amount > 0) {
            // Es importante poner esto a cero porque el receptor
            // puede llamar de nuevo a esta función como parte
            // de la recepción antes de que `send` devuelva su valor.
            pendingReturns[msg.sender] = 0;

            if (!msg.sender.send(amount)) {
                // Aquí no es necesario lanzar una excepción.
                // Basta con reiniciar la cantidad que se debe devolver.
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    /// Finaliza la subasta y envía la puja más alta al beneficiario.
    function auctionEnd() {
        // Es una buena práctica estructurar las funciones que interactúan
        // con otros contratos (i.e. llaman a funciones o envían ether)
        // en tres fases:
        // 1. comprobación de las condiciones
        // 2. ejecución de las acciones (pudiendo cambiar las condiciones)
        // 3. interacción con otros contratos
        // Si estas fases se entremezclasen, otros contratos podrían
        // volver a llamar a este contrato y modificar el estado
        // o hacer que algunas partes (pago de ether) se ejecute multiples veces.
        // Si se llama a funciones internas que interactúan con otros contratos,
        // deben considerarse como interacciones con contratos externos.

        // 1. Condiciones
        require(now >= (auctionStart + biddingTime)); // la subasta aún no ha acabado
        require(!ended); // esta función ya ha sido llamada

        // 2. Ejecución
        ended = true;
        AuctionEnded(highestBidder, highestBid);

        // 3. Interacción
        beneficiary.transfer(highestBid);
    }
}
