pragma solidity ^0.4.11;

contract BlindAuction {
    struct Bid {
        bytes32 blindedBid;
        uint deposit;
    }

    address public beneficiary;
    uint public auctionStart;
    uint public biddingEnd;
    uint public revealEnd;
    bool public ended;

    mapping(address => Bid[]) public bids;

    address public highestBidder;
    uint public highestBid;

    // Retiradas permitidas de pujas previas
    mapping(address => uint) pendingReturns;

    event AuctionEnded(address winner, uint highestBid);

    /// Los modificadores son una forma cómoda de validar los
    /// inputs de las funciones. Abajo se puede ver cómo
    /// `onlyBefore` se aplica a `bid`.
    /// El nuevo cuerpo de la función pasa a ser el del modificador,
    /// sustituyendo `_` por el anterior cuerpo de la función.
    modifier onlyBefore(uint _time) { require(now < _time); _; }
    modifier onlyAfter(uint _time) { require(now > _time); _; }

    function BlindAuction(
        uint _biddingTime,
        uint _revealTime,
        address _beneficiary
    ) {
        beneficiary = _beneficiary;
        auctionStart = now;
        biddingEnd = now + _biddingTime;
        revealEnd = biddingEnd + _revealTime;
    }

    /// Efectúa la puja de manera oculta con `_blindedBid`=
    /// keccak256(value, fake, secret).
    /// El ether enviado sólo se recuperará si la puja se revela de
    /// forma correcta durante la fase de revelacin. La puja es
    /// válida si el ether junto al que se envía es al menos "value"
    /// y "fake" no es cierto. Poner "fake" como verdadero y no enviar
    /// la cantidad exacta, son formas de ocultar la verdadera puja
    /// y aún así realizar el depósito necesario. La misma dirección
    /// puede realizar múltiples pujas.
    function bid(bytes32 _blindedBid)
        payable
        onlyBefore(biddingEnd)
    {
        bids[msg.sender].push(Bid({
            blindedBid: _blindedBid,
            deposit: msg.value
        }));
    }

    /// Revela tus pujas ocultas. Recuperarás los fondos de todas
    /// las pujas inválidas ocultadas de forma correcta y de
    /// todas las pujas salvo en aquellos casos en que sea la más alta.
    function reveal(
        uint[] _values,
        bool[] _fake,
        bytes32[] _secret
    )
        onlyAfter(biddingEnd)
        onlyBefore(revealEnd)
    {
        uint length = bids[msg.sender].length;
        require(_values.length == length);
        require(_fake.length == length);
        require(_secret.length == length);

        uint refund;
        for (uint i = 0; i < length; i++) {
            var bid = bids[msg.sender][i];
            var (value, fake, secret) =
                    (_values[i], _fake[i], _secret[i]);
            if (bid.blindedBid != keccak256(value, fake, secret)) {
                // La puja no ha sido correctamente revelada.
                // No se recuperan los fondos depositados.
                continue;
            }
            refund += bid.deposit;
            if (!fake && bid.deposit >= value) {
                if (placeBid(msg.sender, value))
                    refund -= value;
            }
            // Hace que el emisor no pueda reclamar dos veces
            // el mismo depósito.
            bid.blindedBid = 0;
        }
        msg.sender.transfer(refund);
    }

    // Esta función es "internal", lo que significa que sólo
    // se podrá llamar desde el propio contrato (o contratos
    // que deriven de él).
    function placeBid(address bidder, uint value) internal
            returns (bool success)
    {
        if (value <= highestBid) {
            return false;
        }
        if (highestBidder != 0) {
            // Devolverle el dinero de la puja
            // al anterior pujador con la puja más alta.
            pendingReturns[highestBidder] += highestBid;
        }
        highestBid = value;
        highestBidder = bidder;
        return true;
    }

    /// Retira una puja que ha sido superada.
    function withdraw() returns (bool) {
        var amount = pendingReturns[msg.sender];
        if (amount > 0) {
            // Es importante poner esto a cero porque el receptor
            // puede llamar a esta función de nuevo como parte
            // de la recepción antes de que `send` devuelva su valor.
            // (ver la observacin de arriba sobre condiciones -> efectos
            // -> interacción).
            pendingReturns[msg.sender] = 0;

            if (!msg.sender.send(amount)){
                // Aquí no es necesario lanzar una excepción.
                // Basta con reiniciar la cantidad que se debe devolver.
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    /// Finaliza la subasta y envía la puja más alta
    /// al beneficiario.
    function auctionEnd()
        onlyAfter(revealEnd)
    {
        require(!ended);
        AuctionEnded(highestBidder, highestBid);
        ended = true;
        // Enviamos todo el dinero que tenemos, porque
        // parte de las devoluciones pueden haber fallado.
        beneficiary.transfer(this.balance);
    }
}
