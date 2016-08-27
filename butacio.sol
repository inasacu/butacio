contract Butacio{
    struct Ticket {
        address owner;
        bool used;
        uint price;
        bool onSale;
    }
    
    struct Event {
        uint numTickets;
        uint endDate;
        Ticket[] tickets; // ticket ID to the owner of that ticket
    }
    
    Event ev; // to initialize events
    
    address _owner;
    uint _numEvents;
    Event[] _events;
    
    // Tokens to exchange to EUR
    ButacioToken tokens = new ButacioToken();
    
    event ev_NewEvent(uint eventId, uint numTickets, address manager);
    event ev_TicketOnSale(uint eventId, uint ticketId, uint price);
    event ev_CancelTicketSale(uint eventId, uint ticketId);
    event ev_NewTicketOwner(uint eventId, uint ticketId, address newOwner, uint price);
    event ev_TicketUsed(uint eventId, uint ticketId, address buyer);
    
    function Butacio() {
        _owner = msg.sender;
    }
    
    modifier only_owner() {
        if (msg.sender != _owner) throw;
        _
    }
    
    modifier events_limit(uint eventId) {
        if (_numEvents <= eventId) throw;
        _
    }
    
    modifier tickets_limit(uint eventId, uint ticketId) {
        if (_events[eventId].numTickets <= ticketId) throw;
        _
    }
    
    modifier only_ticket_owner(uint eventId, uint ticketId) {
        if (_events[eventId].tickets[ticketId].owner != msg.sender) throw;
        _
    }
    
    modifier only_unused_tickets(uint eventId, uint ticketId) {
        if (_events[eventId].tickets[ticketId].used == true) throw;
        _
    }
    
    modifier only_tickets_on_sale(uint eventId, uint ticketId) {
        if (_events[eventId].tickets[ticketId].onSale == false) throw;
        _
    }
    
    modifier only_active_events(uint eventId) {
        if (_events[eventId].endDate < now) throw;
        _
    }
    
    // It will proabably fail when there are too many tickets (gas)
    function newEvent(uint _numTickets, uint _endDate, uint[] prices) {
        if(_numTickets != prices.length)
            throw;
        
        // Create the event
        Event e = ev;
        e.numTickets = _numTickets;
        e.endDate = _endDate;
        e.tickets.length = _numTickets;
        
        // Create the tickets
        for(uint i = 0; i < _numTickets; i++){
            e.tickets[i].owner = msg.sender;
            e.tickets[i].price = prices[i];
            e.tickets[i].onSale = true;
        }
        
        uint eventId = _events.push(e);
        _numEvents++;
        
        ev_NewEvent(eventId, _numTickets, msg.sender);
    }
    
    // Quien
    function changeEventEndDate(uint eventId, uint newEndDate)
        only_owner()
        only_active_events(eventId)
    {
        _events[eventId].endDate = newEndDate;
    }
    
    function buyTicket(uint eventId, uint ticketId)
        events_limit(eventId)
        tickets_limit(eventId, ticketId)
        only_tickets_on_sale(eventId, ticketId)
    {
        address ticketOwner = _events[eventId].tickets[ticketId].owner;
        uint ticketPrice = _events[eventId].tickets[ticketId].price;
        
        if (tokens.transfer(ticketOwner, ticketPrice)) {
            _events[eventId].tickets[ticketId].owner = msg.sender;
            
            ev_NewTicketOwner(eventId, ticketId, msg.sender, msg.value);
        }else{
            throw;
        }
    }
    
    function sellTicket(uint eventId, uint ticketId, uint price)
        only_ticket_owner(eventId, ticketId)
        only_unused_tickets(eventId, ticketId)
    {
        _events[eventId].tickets[ticketId].price = price;
        _events[eventId].tickets[ticketId].onSale = true;
        
        ev_TicketOnSale(eventId, ticketId, price);
    }
    
    function cancelTicketSale(uint eventId, uint ticketId)
        only_ticket_owner(eventId, ticketId)
    {
        _events[eventId].tickets[ticketId].onSale = false;
        
        ev_CancelTicketSale(eventId, ticketId);
    }
    
    function sendTicket(uint eventId, uint ticketId, address newOwner)
        only_ticket_owner(eventId, ticketId)
        only_unused_tickets(eventId, ticketId)
    {
        _events[eventId].tickets[ticketId].owner = newOwner;
        
        ev_NewTicketOwner(eventId, ticketId, msg.sender, 0);
    }
    
    function useTicket(uint eventId, uint ticketId)
        only_ticket_owner(eventId, ticketId)
        only_unused_tickets(eventId, ticketId)
    {
        _events[eventId].tickets[ticketId].used = true;
        _events[eventId].tickets[ticketId].onSale = false;
        
        ev_TicketUsed(eventId, ticketId, msg.sender);
    }
}