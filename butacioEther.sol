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
    
    address owner;
    uint numEvents;
    Event[] events;
    
    event e_NewEvent(uint eventId, uint numTickets, address manager);
    event e_TicketOnSale(uint eventId, uint ticketId, uint price);
    event e_CancelTicketSale(uint eventId, uint ticketId);
    event e_NewTicketOwner(uint eventId, uint ticketId, address newOwner, uint price);
    event e_TicketUsed(uint eventId, uint ticketId, address buyer);
    
    function Butacio() {
        owner = msg.sender;
    }
    
    modifier only_owner() {
        if (msg.sender != owner) throw;
        _
    }
    
    modifier events_limit(uint eventId) {
        if (numEvents <= eventId) throw;
        _
    }
    
    modifier tickets_limit(uint eventId, uint ticketId) {
        if (events[eventId].numTickets <= ticketId) throw;
        _
    }
    
    modifier only_ticket_owner(uint eventId, uint ticketId) {
        if (events[eventId].tickets[ticketId].owner != msg.sender) throw;
        _
    }
    
    modifier only_unused_tickets(uint eventId, uint ticketId) {
        if (events[eventId].tickets[ticketId].used == true) throw;
        _
    }
    
    modifier correct_price(uint eventId, uint ticketId) {
        if (events[eventId].tickets[ticketId].price != msg.value) throw;
        _
    }
    
    modifier only_tickets_on_sale(uint eventId, uint ticketId) {
        if (events[eventId].tickets[ticketId].onSale == false) throw;
        _
    }
    
    modifier only_active_events(uint eventId) {
        if (events[eventId].endDate < now) throw;
        _
    }
    
    function newEvent(uint _numTickets, uint _endDate, uint[] prices){
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
        
        uint eventId = events.push(e);
        numEvents++;
        
        e_NewEvent(eventId, _numTickets, msg.sender);
    }
    
    function changeEventEndDate(uint eventId, uint newEndDate)
        only_owner()
        only_active_events(eventId)
    {
        events[eventId].endDate = newEndDate;
    }
    
    function buyTicket(uint eventId, uint ticketId)
        events_limit(eventId)
        tickets_limit(eventId, ticketId)
        only_tickets_on_sale(eventId, ticketId)
        correct_price(eventId, ticketId)
    {
        if(events[eventId].tickets[ticketId].owner.send(msg.value)){
            events[eventId].tickets[ticketId].owner = msg.sender;
        
            e_NewTicketOwner(eventId, ticketId, msg.sender, msg.value);
        }
    }
    
    function sellTicket(uint eventId, uint ticketId, uint price)
        only_ticket_owner(eventId, ticketId)
        only_unused_tickets(eventId, ticketId)
    {
        events[eventId].tickets[ticketId].price = price;
        events[eventId].tickets[ticketId].onSale = true;
        
        e_TicketOnSale(eventId, ticketId, price);
    }
    
    function cancelTicketSale(uint eventId, uint ticketId)
        only_ticket_owner(eventId, ticketId)
    {
        events[eventId].tickets[ticketId].onSale = false;
        
        e_CancelTicketSale(eventId, ticketId);
    }
    
    function sendTicket(uint eventId, uint ticketId, address newOwner)
        only_ticket_owner(eventId, ticketId)
        only_unused_tickets(eventId, ticketId)
    {
        events[eventId].tickets[ticketId].owner = newOwner;
        
        e_NewTicketOwner(eventId, ticketId, msg.sender, 0);
    }
    
    function useTicket(uint eventId, uint ticketId)
        only_ticket_owner(eventId, ticketId)
        only_unused_tickets(eventId, ticketId)
    {
        events[eventId].tickets[ticketId].used = true;
        events[eventId].tickets[ticketId].onSale = false;
        
        e_TicketUsed(eventId, ticketId, msg.sender);
    }
}