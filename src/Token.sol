// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

contract Token {

    string public constant symbol = "tARK";
    string public constant name = "Test Aoraki Token";
    uint256 public constant decimals = 18;
    uint256 public totalSupply = 0;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public minter;
    address public owner;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event MinterChanged(address indexed oldMinter, address indexed newMinter);

    constructor() {
        minter = msg.sender;
        owner = msg.sender;
        _mint(msg.sender, 0);
    }

    function setMinter(address _minter) external {
        require(msg.sender == owner, "Only owner can change the minter");
        emit MinterChanged(minter, _minter);
        minter = _minter;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function token() external view returns (address) {
        return address(this);
    }

    function balance(address account) external view returns (uint) {
        return balanceOf[account];
    }

    function _mint(address _to, uint _amount) internal returns (bool) {
        totalSupply += _amount;
        unchecked {
            balanceOf[_to] += _amount;
        }
        emit Transfer(address(0x0), _to, _amount);
        return true;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool) {
        balanceOf[_from] -= _value;
        unchecked {
            balanceOf[_to] += _value;
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        return _transfer(msg.sender, _to, _value);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {
        uint256 allowed_from = allowance[_from][msg.sender];
        if (allowed_from != type(uint).max) {
            allowance[_from][msg.sender] -= _value;
        }
        return _transfer(_from, _to, _value);
    }

    function mint(address account, uint256 amount) external returns (bool) {
        require(msg.sender == minter);
        _mint(account, amount);
        return true;
    }

    function burn(address account, uint256 amount) external returns (bool) {
        totalSupply -= amount;
        balanceOf[account] -= amount;

        emit Transfer(account, address(0), amount);
        return true;
    }

}
