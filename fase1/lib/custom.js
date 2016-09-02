// Load web3
if (typeof web3 !== 'undefined') {
  web3 = new Web3(web3.currentProvider);
} else {
  web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
}

// Instantiate the JS object to call the contract
var abi = [ { "constant": false, "inputs": [ { "name": "ticketId", "type": "uint256" } ], "name": "punch", "outputs": [ { "name": "ok", "type": "bool" } ], "type": "function" }, { "constant": false, "inputs": [ { "name": "newEndDate", "type": "uint256" } ], "name": "changeEndDate", "outputs": [], "type": "function" }, { "constant": true, "inputs": [ { "name": "ticketId", "type": "uint256" } ], "name": "getTicket", "outputs": [ { "name": "owner", "type": "address", "value": "0x0000000000000000000000000000000000000000" }, { "name": "used", "type": "bool", "value": false } ], "type": "function" }, { "constant": true, "inputs": [], "name": "_owner", "outputs": [ { "name": "", "type": "address", "value": "0x884a6d3b115906bc7d047d63be345218112cb3cf" } ], "type": "function" }, { "constant": false, "inputs": [ { "name": "ticketId", "type": "uint256" }, { "name": "to", "type": "address" } ], "name": "issue", "outputs": [ { "name": "ok", "type": "bool" } ], "type": "function" }, { "constant": false, "inputs": [ { "name": "ticketId", "type": "uint256" }, { "name": "to", "type": "address" } ], "name": "transfer", "outputs": [ { "name": "ok", "type": "bool" } ], "type": "function" }, { "constant": true, "inputs": [], "name": "_numTickets", "outputs": [ { "name": "", "type": "uint256", "value": "10" } ], "type": "function" }, { "constant": true, "inputs": [], "name": "_endDate", "outputs": [ { "name": "", "type": "uint256", "value": "1482847498" } ], "type": "function" }, { "inputs": [ { "name": "numTickets", "type": "uint256", "index": 0, "typeShort": "uint", "bits": "256", "displayName": "num Tickets", "template": "elements_input_uint", "value": "10" }, { "name": "endDate", "type": "uint256", "index": 1, "typeShort": "uint", "bits": "256", "displayName": "end Date", "template": "elements_input_uint", "value": "1482847498" } ], "type": "constructor" }, { "anonymous": false, "inputs": [ { "indexed": false, "name": "ticketId", "type": "uint256" }, { "indexed": false, "name": "to", "type": "address" } ], "name": "ev_Issue", "type": "event" }, { "anonymous": false, "inputs": [ { "indexed": false, "name": "ticketId", "type": "uint256" }, { "indexed": false, "name": "from", "type": "address" }, { "indexed": false, "name": "to", "type": "address" } ], "name": "ev_Transfer", "type": "event" }, { "anonymous": false, "inputs": [ { "indexed": false, "name": "ticketId", "type": "uint256" }, { "indexed": false, "name": "who", "type": "address" } ], "name": "ev_Punch", "type": "event" } ];
var MyContract = web3.eth.contract(abi);
var myContractInstance = MyContract.at("0xbF589F8D0AfcE3f761FDb42efA9584951f82463f");

$(function() {
  // Set a default account
  web3.eth.defaultAccount = web3.eth.accounts[0];

  loadEventInfo();
  loadWalletInfo();
  loadAllTickets();
});

/* Functions to interact with the contract */

function loadEventInfo() {
  $("#eventOwner").text(myContractInstance._owner());
  $("#numTickets").text(myContractInstance._numTickets());

  var d = new Date(myContractInstance._endDate() * 1000);
  $("#endDate").text(d.toLocaleString());
}

function loadWalletInfo() {
  $("#address").text(web3.eth.defaultAccount);
  $("#balance").text(web3.eth.getBalance(web3.eth.defaultAccount));
  $('#myTicketsTable > tbody').html("");

  for(var i = 0; i < myContractInstance._numTickets(); i++){
    if(myContractInstance.getTicket(i)[0] == web3.eth.defaultAccount){
      // Mis tickets
      $('#myTicketsTable > tbody:last-child').append(
      '<tr>'+
        '<td><a href="#" onclick="loadTicketInfo('+ i +')">'+ i +'</a></td>'+
      '</tr>'
      );
    }
  }
}

function loadTicketInfo(id) {
  $("#ticketId").text(id);
  $("#used").text(myContractInstance.getTicket(id)[1]);
}

function loadAllTickets() {
  $('#ticketsTable > tbody').html("");

  for(var i = 0; i < myContractInstance._numTickets(); i++){
    // Tickets
    $('#ticketsTable > tbody:last-child').append(
    '<tr>'+
      '<td>'+ i +'</td>'+
      '<td>'+ myContractInstance.getTicket(i)[1] +'</td>'+
      '<td>'+ myContractInstance.getTicket(i)[0] +'</td>'+
    '</tr>'
    );
  }
}

function send() {
  var id = $("#ticketId").text();
  var to = $("#addrToTransfer").val();
  console.log(id, to);
  myContractInstance.transfer(id, to);
}

function punch() {
  var id = $("#ticketId").text();

  myContractInstance.punch(id);
}

function issue() {
  var id = $("#ticketIdToIssue").val();
  var to = $("#addrToIssue").val();

  myContractInstance.issue(id, to);
}

function changeEndDate() {
  var timestamp = $("#newEndDate").val();

  myContractInstance.changeEndDate(timestamp);
}

/* Functions to interact with the HTML */

function showInfo(msg, isError){
  var msgClass = "alert-info";

  if(isError)
    msgClass = "alert-danger";

  var html = '<div class="alert ' + msgClass + ' alert-dismissible" role="alert">' +
               '<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>' +
               '<b>' + msg + '</b><br>' +
             '</div>';

  $("#info").html(html);
}

/* To watch for events */

myContractInstance.ev_Issue(function(error, result) {
  if (!error){
    showInfo("Entrada vendida ("+ result.args.ticketId.toNumber() +" -> "+ result.args.to +")", false);
    loadWalletInfo();
    loadAllTickets();
    console.log(result.args);
  }
});

myContractInstance.ev_Transfer(function(error, result) {
  if (!error){
    showInfo("Transferencia ("+ result.args.from +" -- ["+ result.args.ticketId.toNumber() +"] --> "+ result.args.to +")", false);
    loadWalletInfo();
    loadAllTickets();
    console.log(result.args);
  }
});

myContractInstance.ev_Punch(function(error, result) {
  if (!error){
    showInfo("Ticket usado ("+ result.args.ticketId.toNumber() +" -> "+ result.args.who +")", false);
    loadAllTickets();
    console.log(result.args);
  }
});
