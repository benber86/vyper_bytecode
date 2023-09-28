# @version ^0.3.9

amounts: public(HashMap[address, uint256])

@external
def increase():
    self.amounts[msg.sender] += 1
