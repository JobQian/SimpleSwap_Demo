// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./IERC20.sol";

contract ERC20 is IERC20 {
    mapping(address => uint256) public override balanceOf;

    mapping(address => mapping(address => uint256)) public override allowance;

    uint256 public override totalSupply;   // 代币总供给

    string public name;   // 名称
    string public symbol;  // 代号

    uint8 public decimals = 18; // 小数位数

    constructor(string memory name_, string memory symbol_){
        name = name_;
        symbol = symbol_;
    }

    /*
    transfer()函数：实现IERC20中的transfer函数，代币转账逻辑。
    调用方扣除amount数量代币，接收方增加相应代币。
    土狗币会魔改这个函数，加入税收、分红、抽奖等逻辑。
    */
    function transfer(address recipient, uint amount) public override returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    /*
    approve()函数：实现IERC20中的approve函数，代币授权逻辑。
    被授权方spender可以支配授权方的amount数量的代币。
    spender可以是EOA账户，也可以是合约账户：当你用uniswap交易代币时，你需要将代币授权给uniswap合约。
    */
    function approve(address spender, uint amount) public override returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /*
    transferFrom()函数：实现IERC20中的transferFrom函数，授权转账逻辑。
    被授权方将授权方sender的amount数量的代币转账给接收方recipient。
    */
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) public override returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    /*
    mint()函数：铸造代币函数，不在IERC20标准中。
    */
    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    /*
    burn()函数：销毁代币函数，不在IERC20标准中。
    */
    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

}


contract Faucet{

    uint256 public amountAllowed = 100; // 每次领 100 单位代币

    address public tokenContract;   // token合约地址

    mapping(address => bool) public requestedAddress;   // 记录领取过代币的地址

    // SendToken事件    
    event SendToken(address indexed Receiver, uint256 indexed Amount); 

    // 部署时设定ERC20代币合约
    constructor(address _tokenContract) {
        tokenContract = _tokenContract; // set token contract
    }

    // 用户领取代币函数
    function requestTokens() external {
        require(!requestedAddress[msg.sender], "Can't Request Multiple Times!"); // 每个地址只能领一次
        IERC20 token = IERC20(tokenContract); // 创建IERC20合约对象
        require(token.balanceOf(address(this)) >= amountAllowed, "Faucet Empty!"); // 水龙头空了

        token.transfer(msg.sender, amountAllowed); // 发送token
        requestedAddress[msg.sender] = true; // 记录领取地址 
        
        emit SendToken(msg.sender, amountAllowed); // 释放SendToken事件
    }

}

