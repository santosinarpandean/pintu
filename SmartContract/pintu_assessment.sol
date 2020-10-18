pragma solidity >=0.4.22 <0.7.0;

/* --- Author: Santo Sinar Pandean --- */
/* --- Created at 18 October 2020 --- */
/* --- Notes: Since we dont use safeMath library, can ignore the overflow issue --- */
contract PintuAssessment {
    uint256 counter = 0;

    mapping(address => uint256) balances;

    event Received(address, uint256);
    event Withdrawal(address, uint256);

    function incrementCounter() public {
        counter += 1;
    }

    function getCounter() external view returns (uint256) {
        return counter;
    }

    function balanceOf(address _addr) external view returns (uint256) {
        return balances[_addr];
    }

    /* --- Current Use Case: minimum withdrawal 1 ETHER --- */
    function withdraw(uint256 _total_withdrawal) external {
        require(_total_withdrawal >= 1 ether, "Minimum withdrawal is 1 ether");
        require(
            balances[msg.sender] >= _total_withdrawal,
            "Recipient balance is not sufficient"
        );
        require(counter >= 10, "Counter less than 10!");

        balances[msg.sender] -= _total_withdrawal;
        (bool success, ) = msg.sender.call{value: _total_withdrawal}("");
        require(success, "Sending amount withdrawal is failed");
        emit Withdrawal(msg.sender, _total_withdrawal);
    }

    receive() external payable {
        require(msg.value >= 1 ether, "Minimum deposit is 1 ether");
        address sender = msg.sender;
        uint256 total_deposit = msg.value;
        balances[sender] += total_deposit;
        emit Received(msg.sender, msg.value);
    }
}
