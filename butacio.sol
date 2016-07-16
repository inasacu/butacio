contract Butacio{
    struct Ticket {
        address owner;
        bool used;
        bool exchange;
        uint exchangePrice; // in cents of euro
    }
    
    struct Event {
        address manager;
        uint numTickets;
        uint endDate;
        Ticket[] tickets; // ticket ID to the owner of that ticket
    }
    Event ev; // to initialize events
    
    address public owner;
    uint public numEvents;
    Event[] public events;
    
    //mapping(address => uint[]) eventsPerManager; // ID of the events owned by a manager
    //mapping(address => uint[][]) ticketsPerUser; // ID of the tickets per event owned by a user. TODO
    
    event e_NewEvent(uint eventId, uint numTickets, address manager);
    event e_NewEventEndDate(uint eventId, uint date);
    event e_NewTicketOwner(uint eventId, uint ticketId, address newOwner);
    event e_TicketUsed(uint eventId, uint ticketId, address user);
    event e_TicketSentToExchange(uint eventId, uint ticketId, uint price);
    event e_TicketSoldFromExchange(uint eventId, uint ticketId, uint price);
    event e_TicketRemovedFromExchange(uint eventId, uint ticketId);
    
    function Butacio() {
        owner = msg.sender;
    }
    
    modifier only_admin() {
        if (msg.sender == owner) _
    }
    
    /*
    modifier events_limit(uint eventId) {
        if (numEvents > eventId) _
    }
    
    modifier tickets_limit(uint eventId, uint ticketId) {
        if (events[eventId].numTickets > ticketId) _
    }
    */
    modifier only_event_manager(uint eventId) {
        if (events[eventId].manager == msg.sender) _
    }
    
    modifier only_ticket_owner(uint eventId, uint ticketId) {
        if (events[eventId].tickets[ticketId].owner == msg.sender) _
    }
    
    modifier only_new_tickets(uint eventId, uint ticketId) {
        if (events[eventId].tickets[ticketId].owner == 0) _
    }
    
    modifier only_unused_tickets(uint eventId, uint ticketId) {
        if (events[eventId].tickets[ticketId].used == false) _
    }
    
    modifier only_active_events(uint eventId) {
        if (events[eventId].endDate > now) _
    }
    
    modifier only_tickets_on_exchange(uint eventId, uint ticketId) {
        if (events[eventId].tickets[ticketId].exchange == true) _
    }
    
    function newEvent(uint _numTickets, uint _endDate){
        // Create the event
        Event e = ev;
        e.manager = msg.sender;
        e.numTickets = _numTickets;
        e.endDate = _endDate;
        e.tickets.length = _numTickets;
        
        uint eventId = events.push(e);
        numEvents++;
        
        //eventsPerManager[msg.sender].push(eventId);
        
        e_NewEvent(eventId, _numTickets, msg.sender);
    }
    
    function changeEventEndDate(uint eventId, uint newEndDate)
        only_event_manager(eventId)
        only_active_events(eventId)
    {
        events[eventId].endDate = newEndDate;
        
        e_NewEventEndDate(eventId, newEndDate);
    }
    
    function sellTicket(uint eventId, uint ticketId, address newOwner)
        only_admin()
        only_active_events(eventId)
        only_new_tickets(eventId, ticketId)
    {
        events[eventId].tickets[ticketId].owner = newOwner;
        
        e_NewTicketOwner(eventId, ticketId, newOwner);
    }
    
    function sendTicketToExchange(uint eventId, uint ticketId, uint price)
        only_ticket_owner(eventId, ticketId)
        only_unused_tickets(eventId, ticketId)
        only_active_events(eventId)
    {
        events[eventId].tickets[ticketId].exchange = true;
        events[eventId].tickets[ticketId].exchangePrice = price;
        
        e_TicketSentToExchange(eventId, ticketId, price);
    }
    
    function sellTicketFromExchange(uint eventId, uint ticketId, address newOwner)
        only_admin()
        only_tickets_on_exchange(eventId, ticketId)
    {
        events[eventId].tickets[ticketId].owner = newOwner;
        events[eventId].tickets[ticketId].exchange = false;
        
        e_TicketSoldFromExchange(eventId, ticketId, events[eventId].tickets[ticketId].exchangePrice);
        e_NewTicketOwner(eventId, ticketId, newOwner);
    }
    
    function removeTicketFromExchange(uint eventId, uint ticketId)
        only_ticket_owner(eventId, ticketId)
        only_unused_tickets(eventId, ticketId)
        only_active_events(eventId)
    {
        events[eventId].tickets[ticketId].exchange = false;
        
        e_TicketRemovedFromExchange(eventId, ticketId);
    }
    /*
    function sendTicket(uint eventId, uint ticketId, address newOwner)
        only_ticket_owner(eventId, ticketId)
        only_unused_tickets(eventId, ticketId)
    {
        events[eventId].tickets[ticketId].owner = newOwner;
        
        e_NewTicketOwner(eventId, ticketId, newOwner, false);
    }
    */
    function useTicket(uint eventId, uint ticketId)
        only_ticket_owner(eventId, ticketId)
        only_unused_tickets(eventId, ticketId)
    {
        events[eventId].tickets[ticketId].used = true;
        
        e_TicketUsed(eventId, ticketId, msg.sender);
    }
}