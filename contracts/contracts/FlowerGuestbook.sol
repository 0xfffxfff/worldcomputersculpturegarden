// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solady/src/auth/Ownable.sol";

contract FlowerGuestbook is Ownable {

    uint256 public flowers;
    mapping(address => uint256) public flowersPlantedBy;
    mapping(uint256 => address) private flowerBy;

    constructor () {
        _initializeOwner(msg.sender);
    }

    receive() external payable {
        if (msg.value < 0.01 ether) {
            return;
        }
        uint256 newFlowers = msg.value / 0.01 ether;
        flowersPlantedBy[msg.sender] += newFlowers;
        flowers += newFlowers;
        flowerBy[flowers] = msg.sender;
    }

    function flower(uint256 flowerId) external view returns (address) {
        require(0 < flowerId && flowerId <= flowers, "Index out of bounds");
        while (flowerId <= flowers) {
            if (flowerBy[flowerId] != address(0)) {
                break;
            }
            flowerId++;
        }
        return flowerBy[flowerId];
    }

    function withdraw(address _to) external onlyOwner() {
        (bool success, ) = _to.call{value: address(this).balance}("");
        require(success, "Failed to withdraw");
    }
}