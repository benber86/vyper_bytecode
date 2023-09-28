# @version ^0.3.9

@external
def addNumber(number: uint256) -> uint256:
    total: uint256 = 0
    
    for i in range(100):
        total += number
    
    return total
