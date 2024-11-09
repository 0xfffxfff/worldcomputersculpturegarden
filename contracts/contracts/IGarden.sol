// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

interface IGarden {
    function getSculptures() external view returns (address[] memory);
    function flower(uint256 flowerId) external view returns (address);
    function flowers() external view returns (uint256);
    function flowersPlanted(address planter) external view returns (uint256);
    function flowerPlantedAt(uint256 flowerId) external view returns (uint256);
    function flowerInfo(uint256 flowerId) external view returns (address planter, uint256 timestamp);
    function guests() external view returns (uint256);
}