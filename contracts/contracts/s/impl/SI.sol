// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../S.sol";

contract SI {
    address immutable public origin;
    address immutable public sp;

    constructor(address _sp) {
        sp = _sp;
        origin = tx.origin;
    }

    receive() external payable {
        if (msg.sender == sp) {
            return;
        }
        S(sp).sign(msg.sender, address(this));
    }

    function withdraw() external {
        (bool success, ) = origin.call{value: address(this).balance}("");
        require(success, "SI: withdraw failed");
    }
}