// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SP {
    event Signed(address indexed who, address indexed recepient, uint256 value);

    uint256 public registrationCount;
    mapping(address => uint256) public registeredAddressIndex;
    mapping(address => uint256) public contributionsReceivedByAddress;
    mapping(address => uint256) public contributionsMadeByAddress;

    address immutable public origin;

    constructor() {
        origin = msg.sender;
        _register(address(this));
    }

    function sign(address _who, address _recipient) public payable {
        // Register Recipient
        if (registeredAddressIndex[_recipient] == 0) {
            _register(_who);
        }

        // Track contributions
        contributionsMadeByAddress[_who] += msg.value;
        contributionsReceivedByAddress[_recipient] += msg.value;

        // Forward contribution
        (bool success, ) = _recipient.call{value: msg.value}("");
        require(success, "Failed to sign");

        // Emit Signed Event
        emit Signed(_who, _recipient, msg.value);
    }

    function _register(address _contract) internal {
        registrationCount++; // Start at 1
        registeredAddressIndex[_contract] = registrationCount;
    }

    receive() external payable {
        sign(msg.sender, address(this));
    }
}