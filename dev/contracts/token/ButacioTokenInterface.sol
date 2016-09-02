contract ButacioTokenInterface {
  string public symbol;

  /// @notice creates `value` tokens in `to` account
  /// @param to The address of the recipient
  /// @param value The amount of token to be created
  /// @return Whether the creation was successful or not
  function create(address to, uint value) returns (bool ok);

  /// @notice Burns `value` tokens from `msg.sender`
  /// @param value The amount of token to be burned
  /// @return Whether the burn was successful or not
  function burn(uint value) returns (bool ok);

  /// @notice Changes current symbol to `symbol`
  /// @param symbol The new symbol of the token
  function setSymbol(string symbol);

  event Creation(address indexed to, uint value);
  event Burn(uint value);
}
