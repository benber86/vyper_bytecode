# @version 0.3.9
from vyper.interfaces import ERC20

implements: ERC20

event Approval:
    _owner: indexed(address)
    _spender: indexed(address)
    _value: uint256

event Transfer:
    _from: indexed(address)
    _to: indexed(address)
    _value: uint256

EIP712_TYPEHASH: constant(bytes32) = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")
PERMIT_TYPEHASH: constant(bytes32) = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")

VERSION: constant(String[8]) = "v1.0.0"


NAME: immutable(String[32])
SYMBOL: immutable(String[32])
DECIMALS: immutable(uint8)
TOTAL_SUPPLY: immutable(uint256)
DOMAIN_SEPARATOR: immutable(bytes32)

balanceOf: public(HashMap[address, uint256])
allowance: public(HashMap[address, HashMap[address, uint256]])
nonces: public(HashMap[address, uint256])


@external
def __init__(_name: String[32], _symbol: String[32], _decimals: uint8, _supply: uint256):
    NAME = _name
    SYMBOL = _symbol
    DECIMALS = _decimals
    TOTAL_SUPPLY = _supply
    self.balanceOf[msg.sender] = _supply

    DOMAIN_SEPARATOR = keccak256(
        _abi_encode(EIP712_TYPEHASH, keccak256(NAME), keccak256(VERSION), chain.id, self)
    )

    # fire a transfer event so block explorers identify the contract as an ERC20
    log Transfer(ZERO_ADDRESS, msg.sender, _supply)

@external
def transfer(_to: address, _value: uint256) -> bool:
    """
    @dev Transfer token for a specified address
    @param _to The address to transfer to.
    @param _value The amount to be transferred.
    """
    # NOTE: vyper does not allow underflows
    #       so the following subtraction would revert on insufficient balance
    self.balanceOf[msg.sender] -= _value
    self.balanceOf[_to] += _value

    log Transfer(msg.sender, _to, _value)
    return True


@external
def transferFrom(_from: address, _to: address, _value: uint256) -> bool:
    """
     @dev Transfer tokens from one address to another.
     @param _from address The address which you want to send tokens from
     @param _to address The address which you want to transfer to
     @param _value uint256 the amount of tokens to be transferred
    """
    self.balanceOf[_from] -= _value
    self.balanceOf[_to] += _value

    _allowance: uint256 = self.allowance[_from][msg.sender]
    if _allowance != MAX_UINT256:
        self.allowance[_from][msg.sender] = _allowance - _value

    log Transfer(_from, _to, _value)
    return True


@external
def approve(_spender: address, _value: uint256) -> bool:
    self.allowance[msg.sender][_spender] = _value

    log Approval(msg.sender, _spender, _value)
    return True


@external
def permit(
    _owner: address,
    _spender: address,
    _value: uint256,
    _deadline: uint256,
    _v: uint8,
    _r: bytes32,
    _s: bytes32
) -> bool:
    assert _owner != ZERO_ADDRESS
    assert block.timestamp <= _deadline

    nonce: uint256 = self.nonces[_owner]
    digest: bytes32 = keccak256(
        concat(
            b"\x19\x01",
            DOMAIN_SEPARATOR,
            keccak256(_abi_encode(PERMIT_TYPEHASH, _owner, _spender, _value, nonce, _deadline))
        )
    )

    assert ecrecover(digest, convert(_v, uint256), convert(_r, uint256), convert(_s, uint256)) == _owner

    self.allowance[_owner][_spender] = _value
    self.nonces[_owner] = nonce + 1

    log Approval(_owner, _spender, _value)
    return True

@view
@external
def name() -> String[32]:
    return NAME


@view
@external
def symbol() -> String[32]:
    return SYMBOL


@view
@external
def decimals() -> uint8:
    return DECIMALS

@view
@external
def totalSupply() -> uint256:
    return TOTAL_SUPPLY


@view
@external
def version() -> String[8]:
    return VERSION
