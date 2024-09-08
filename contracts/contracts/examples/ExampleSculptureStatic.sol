// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "../Sculpture.sol";

contract ExampleSculptureStatic is Sculpture {

    function title() external pure override returns (string memory) {
        return "Static Example Sculpture Title";
    }

    function authors() external view override returns (string[] memory) {
        string[] memory authors_ = new string[](1);
        authors_[0] = "John Doe";
        return authors_;
    }

    function addresses() external view override returns (address[] memory) {
        address[] memory addresses_ = new address[](1);
        addresses_[0] = address(this);
        return addresses_;
    }

    function text() public view override returns (string memory) {
        return "This is an example sculpture that is static.";
    }

    function urls() public view override returns (string[] memory urls) {} // empty
}