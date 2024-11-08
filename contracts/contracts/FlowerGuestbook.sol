// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solady/src/auth/Ownable.sol";

contract FlowerGuestbook is Ownable {

    uint256 private totalFlowers;
    uint256 private totalGuests;
    mapping(address => uint256) private flowersPlantedBy;
    mapping(uint256 => address) private flowerBy;
    mapping(uint256 => uint256) private flowerTimestamp;

    constructor () {
        _initializeOwner(msg.sender);
    }

    receive() external payable {
        if (msg.value < 0.01 ether) {
            return;
        }
        uint256 newFlowers = msg.value / 0.01 ether;
        if (flowersPlantedBy[msg.sender] == 0) {
            totalGuests++;
        }
        flowersPlantedBy[msg.sender] += newFlowers;
        totalFlowers += newFlowers;
        flowerBy[totalFlowers] = msg.sender;
        flowerTimestamp[totalFlowers] = block.timestamp;
    }

    function flower(uint256 flowerId) external view returns (address) {
        require(0 < flowerId && flowerId <= totalFlowers, "Index out of bounds");
        while (flowerId <= totalFlowers) {
            if (flowerBy[flowerId] != address(0)) {
                break;
            }
            flowerId++;
        }
        return flowerBy[flowerId];
    }

    function flowers() external view returns (uint256) {
        return totalFlowers;
    }

    function flowerPlantedAt(uint256 flowerId) external view returns (uint256) {
        require(0 < flowerId && flowerId <= totalFlowers, "Index out of bounds");
        while (flowerId <= totalFlowers) {
            if (flowerTimestamp[flowerId] != 0) {
                break;
            }
            flowerId++;
        }
        return flowerTimestamp[flowerId];
    }

    function flowersPlanted(address planter) external view returns (uint256) {
        return flowersPlantedBy[planter];
    }

    function guests() external view returns (uint256) {
        return totalGuests;
    }

    function withdraw(address _to) external onlyOwner() {
        (bool success, ) = _to.call{value: address(this).balance}("");
        require(success, "Failed to withdraw");
    }

    function flowerInfo(uint256 flowerId) external view returns (address planter, uint256 timestamp) {
        require(0 < flowerId && flowerId <= totalFlowers, "Index out of bounds");
        while (flowerId <= totalFlowers) {
            if (flowerBy[flowerId] != address(0)) {
                break;
            }
            flowerId++;
        }
        return (
            flowerBy[flowerId],
            flowerTimestamp[flowerId]
        );
    }
}