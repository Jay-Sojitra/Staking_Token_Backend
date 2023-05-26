// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "hardhat/console.sol";

contract StakingToken is ERC20 {
    string public _name;
    string public _symbol;
    uint8 public _decimals;
    uint256 public _totalRewards;
    uint public tokenCount;

    struct Stake {
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => Stake) public _stakes;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount, uint256 rewards);

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply
    ) ERC20(name_, symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _mint(address(this), initialSupply);
        tokenCount = initialSupply;
    }

    function mint(uint256 amount) external {
        require(msg.sender != address(0), "Invalid address");
        _mint(msg.sender, amount);
        tokenCount += amount;
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(
            balanceOf(msg.sender) >= amount,
            "Insufficient balance for staking"
        );
        require(_stakes[msg.sender].amount == 0, "You can only stake one time");
        

        _transfer(msg.sender, address(this), amount);
        _stakes[msg.sender] = Stake(amount, block.timestamp);

        emit Staked(msg.sender, amount);
    }

    function unstake() external {
        require(_stakes[msg.sender].amount > 0, "No staked amount found");

        uint256 stakedAmount = _stakes[msg.sender].amount;
        uint256 stakedTimestamp = _stakes[msg.sender].timestamp;
        delete _stakes[msg.sender];

        uint256 rewards = calculateRewards(stakedAmount, stakedTimestamp);

        _transfer(address(this), msg.sender, stakedAmount + rewards);

        emit Unstaked(msg.sender, stakedAmount, rewards);
    }

    function calculateRewards(
        uint256 amount,
        uint256 timestamp
    ) private returns (uint256) {
        uint256 stakingDuration = block.timestamp - timestamp;
        uint256 rewards = (amount * stakingDuration) / 1 days;
        _totalRewards = _totalRewards + rewards;
        if (balanceOf(address(this)) < rewards) {
            uint256 mintAmount = rewards - balanceOf(address(this));
            _mint(address(this), mintAmount);
        }
        return rewards;
    }

    function totalRewards() external view returns (uint256) {
        return _totalRewards;
    }
}
