contract Butacio{
    struct Ticket {
        address owner;
        bool used;
    }

    address public _owner;
    uint public _numTickets;
    uint public _endDate;
    mapping(uint => Ticket) _tickets;

    event ev_Issue(uint ticketId, address to);
    event ev_Transfer(uint ticketId, address from, address to);
    event ev_Punch(uint ticketId, address who);

    modifier only_owner() {
        if (msg.sender != _owner) throw;
        _
    }

    modifier only_ticket_owner(uint ticketId) {
        if (_tickets[ticketId].owner != msg.sender) throw;
        _
    }

    modifier only_tickets_in_range(uint ticketId) {
        if (ticketId >= _numTickets) throw;
        _
    }

    modifier only_new_tickets(uint ticketId) {
        if (_tickets[ticketId].owner != address(0)) throw;
        _
    }

    modifier only_unused_tickets(uint ticketId) {
        if (_tickets[ticketId].used == true) throw;
        _
    }

    modifier only_before_endDate() {
        if (_endDate < now) throw;
        _
    }

    function Butacio(uint numTickets, uint endDate) {
        _owner = msg.sender;
        _numTickets = numTickets;
        _endDate = endDate;
    }

    function changeEndDate(uint newEndDate)
        only_owner()
        only_before_endDate()
    {
        _endDate = newEndDate;
    }

    function issue(uint ticketId, address to)
        only_owner()
        only_tickets_in_range(ticketId)
        only_new_tickets(ticketId)
        only_before_endDate()
        returns(bool ok)
    {
        _tickets[ticketId].owner = to;

        ev_Issue(ticketId, to);

        return true;
    }

    function transfer(uint ticketId, address to)
        only_ticket_owner(ticketId)
        only_unused_tickets(ticketId)
        only_before_endDate()
        returns(bool ok)
    {
        _tickets[ticketId].owner = to;

        ev_Transfer(ticketId, msg.sender, to);

        return true;
    }

    function punch(uint ticketId)
        only_ticket_owner(ticketId)
        only_unused_tickets(ticketId)
        only_before_endDate()
        returns(bool ok)
    {
        _tickets[ticketId].used = true;

        ev_Punch(ticketId, msg.sender);

        return true;
    }

    function getTicket(uint ticketId) constant returns(address owner, bool used) {
        owner = _tickets[ticketId].owner;
        used = _tickets[ticketId].used;
    }
}
