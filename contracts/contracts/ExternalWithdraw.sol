// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

////////////////////////////////////////////////////////////////////////
//                                                                    //
//    External Withdraw ⚘                                             //
//                                                                    //
//    This contract allows revoking the ownership of the garden       //
//    by transferring it's ownership to this contract. This way       //
//    the balance of the garden contract can still be withdrawn       //
//    while all other functions are not longer accessible, as         //
//    this contract cannot transfer the ownership of the garden.      //
//                                                                    //
////////////////////////////////////////////////////////////////////////

import "@openzeppelin/contracts/access/Ownable.sol";

interface IWithdraw {
    function withdraw(address _to) external;
}

contract ExternalWithdraw is Ownable, IWithdraw {

    address immutable public garden;

    constructor (address _garden) Ownable(msg.sender) {
        garden = _garden;
    }

    function withdraw(address _to) external onlyOwner {
        IWithdraw(garden).withdraw(_to);
    }
}