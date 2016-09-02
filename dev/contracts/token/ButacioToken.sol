import "ButacioTokenInterface.sol";
import "../Utils.sol";

contract ButacioToken is ButacioTokenInterface, ERC20, Utils {
  address public _admin;
  string public _symbol;

  function ButacioToken(address admin, string symbol) {
      _admin = admin;
      _symbol = symbol;
  }

  function create(address to, uint value)
    only_executed_by(_admin)
    is_safe_to_add(_supply, value)
    returns(bool ok)
  {
    _balances[to] += value;
    _supply += value;

    Creation(to, value);

    return true;
  }

  function burn(uint value)
    only_executed_by(_admin)
    has_enough_funds(_admin, value)
    returns(bool ok)
  {
    _balances[_admin] -= value;
    _supply -= value;

    Burn(value);

    return true;
  }

  function setSymbol(string symbol)
    only_executed_by(_admin)
  {
    _symbol = symbol;
  }
}
