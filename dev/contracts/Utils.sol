contract Utils(){
  modifier only_executed_by(address who){
      if (msg.sender != who) throw;
      _
  }

  modifier is_safe_to_add(uint a, uint b){
      if (a + b < a) throw;
      _
  }
}
