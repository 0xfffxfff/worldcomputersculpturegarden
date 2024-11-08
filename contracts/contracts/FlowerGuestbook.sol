// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "solady/src/auth/Ownable.sol";

contract FlowerGuestbook is Ownable {

    uint256 public totalFlowers;
    mapping(address => uint256) public flowers;
    mapping(uint256 => address) public flowerIndex;

    constructor () {
        _initializeOwner(msg.sender);
    }

    receive() external payable {
        if (msg.value < 0.01 ether) {
            return;
        }
        uint256 flowerCount = msg.value / 0.01 ether;
        flowers[msg.sender] += flowerCount;
        totalFlowers += flowerCount;
        flowerIndex[totalFlowers - 1] = msg.sender;
    }

    function ownerOf(uint256 _index) public view returns (address) {
        require(_index < totalFlowers, "Index out of bounds");
        address owner = flowerIndex[_index];
        while (_index < totalFlowers) {
            _index++;
            if (flowerIndex[_index] == address(0)) continue;
            owner = flowerIndex[_index];
            break;
        }
        return owner;
    }

    function withdraw(address _to) public onlyOwner() {
        (bool success, ) = _to.call{value: address(this).balance}("");
        require(success, "Failed to withdraw");
    }
}