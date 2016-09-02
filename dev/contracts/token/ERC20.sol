import "ERC20Interface.sol";
import "../Utils.sol";

contract ERC20 is ERC20Interface, Utils {
  mapping (address => uint) _balances;
  mapping (address => mapping (address => uint)) _allowed;
  uint _supply:

  modifier has_enough_funds(address who, uint value){
      if (_balances[who] < value) throw;
      _
  }

  modifier is_allowed(address who, address from, uint value){
      if (_allowed[from][who] < value) throw;
      _
  }

  function transfer(address to, uint value)
    has_enough_funds(msg.sender, value)
    is_safe_to_add(balances[to], value)
    returns (bool ok)
  {
    _balances[msg.sender] -= value;
    _balances[to] += value;

    Transfer(msg.sender, to, value);

    return true;
  }

  function transferFrom(address from, address to, uint value)
    has_enough_funds(from, value)
    is_allowed(msg.sender, from, value)
    is_safe_to_add(_balances[to], value)
    returns (bool ok)
  {
    _balances[to] += value;
    _balances[from] -= value;
    _allowed[from][msg.sender] -= value;

    Transfer(from, to, value);

    return true;
  }

  function approve(address spender, uint value) returns (bool ok) {
    _allowed[msg.sender][spender] = value;

    Approval(msg.sender, spender, value);

    return true;
  }

  function totalSupply() constant returns (uint value) {

    return _supply;
  }

  function balanceOf(address who) constant returns (uint value) {

    return _balances[who];
  }

  function allowance(address owner, address spender) constant returns (uint remaining) {

    return _allowed[owner][spender];
  }
}
