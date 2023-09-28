# @version ^0.3.9

struct VyperStruct:
    foo: uint256
    bar: bool
    baz: uint256
    
user_structs: public(HashMap[address, VyperStruct])

@external
def a(b: uint256) -> VyperStruct:
	c: VyperStruct = VyperStruct({foo: b, bar: b & 1 == 0, baz: b**2})
	return c
	
	 
@external
def k(b: uint256):
	if (self.user_structs[msg.sender].foo == 0):
		self.user_structs[msg.sender] = VyperStruct({foo: b, bar: b & 1 == 0, baz: b**2})
