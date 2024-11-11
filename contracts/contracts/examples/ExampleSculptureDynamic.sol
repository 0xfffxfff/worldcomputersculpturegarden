// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solady/src/utils/LibString.sol";
import "../Sculpture.sol";

contract ExampleSculptureDynamic is Sculpture {

    function title() external view override returns (string memory) {
        // This title is dynamic and always shows the current block timestamp
        return string.concat("Dynamic Title (", block.number % 2 == 0 ? "Even Block" : "Odd Block" ,")");
    }

    function authors() external view override returns (string[] memory) {
        string[] memory authors_ = new string[](1);
        authors_[0] = block.number % 2 == 0 ? "Artist (Happy)" : "Artist (Sad)";
        return authors_;
    }

    function addresses() external view override returns (address[] memory) {
        address[] memory addresses_ = new address[](1);
        // this too, could be dynamic or change over time
        addresses_[0] = address(this);
        return addresses_;
    }

    function text() public view override returns (string memory) {
        // example text with a timestamp and block number
        return string.concat("This is an example that is dynamicly rendering it's fields.<br/> Block number: ", LibString.toString(block.number), " / Timestamp: ", LibString.toString(block.timestamp));
    }

    function urls() public view override returns (string[] memory urls) {} // empty
}