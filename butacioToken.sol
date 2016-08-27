contract ERC20 {
    function totalSupply() constant returns (uint supply);
    function balanceOf(address who) constant returns (uint value);
    //function allowance(address owner, address spender) constant returns (uint _allowance);
    function transfer(address to, uint value) returns (bool ok);
    //function transferFrom(address from, address to, uint value) returns (bool ok);
    //function approve(address spender, uint value) returns (bool ok);
    
    event Transfer(address indexed from, address indexed to, uint value);
    //event Approval(address indexed owner, address indexed spender, uint value);
}

contract ButacioToken is ERC20 {
    mapping(address => uint) _balances;
    uint _supply;
    address admin;
    
    modifier only_executed_by(address user){
        if (msg.sender != user) throw;
        _
    }
    
    modifier has_enough_funds(address user, uint value){
        if (_balances[user] < value) throw;
        _
    }
    
    modifier is_safe_to_add(uint a, uint b){
        if (a + b < a) throw;
        _
    }
    
    function ButacioToken() {
        admin = msg.sender;
    }
    
    function createTokens(uint value)
        only_executed_by(admin)
    {
        _balances[admin] += value;
        _supply += value;
    }
    
    function burnTokens(uint value)
        only_executed_by(admin)
        has_enough_funds(msg.sender, value)
    {
        _balances[admin] -= value;
        _supply -= value;
    }
    
    // EIP20
    function totalSupply() constant returns (uint supply) {
        return _supply;
    }
    
    // EIP20
    function balanceOf(address who) constant returns (uint value) {
        return _balances[who];
    }
    
    // EIP20
    function transfer(address to, uint value)
        has_enough_funds(msg.sender, value)
        is_safe_to_add(_balances[to], value)
        returns (bool ok)
    {
        _balances[msg.sender] -= value;
        _balances[to] += value;
        
        Transfer(msg.sender, to, value);
        
        return true;
    }
}