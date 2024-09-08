// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

interface Sculpture {

    function title() external view returns (string memory);

    function authors() external view returns (string[] memory);

    function addresses() external view returns (address[] memory);

    function urls() external view returns (string[] memory);

    function text() external view returns (string memory);
    
}
