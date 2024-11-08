// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import "solady/src/auth/Ownable.sol";
import "solady/src/utils/SSTORE2.sol";
import "./Sculpture.sol";

contract Essay is Sculpture, Ownable {

    address private pointer;
    string private t;
    string[] private u;

    constructor () {
        _initializeOwner(msg.sender);
    }

    function title() external view returns (string memory) {
        return t;
    }

    function authors() external pure returns (string[] memory authors_) {
        authors_ = new string[](1);
        authors_[0] = "Malte Rauch";
        return authors_;
    }

    function addresses() external view returns (address[] memory) {
        address[] memory _addresses = new address[](1);
        _addresses[0] = address(this);
        return _addresses;
    }

    function urls() external view returns (string[] memory) {
        return u;
    }

    function text() external view returns (string memory) {
        return string(SSTORE2.read(pointer));
    }

    function setTitles(string memory _title) external onlyOwner {
        t = _title;
    }

    function setUrls(string[] memory _urls) external onlyOwner {
        u = _urls;
    }

    function setText(string memory _text) external onlyOwner {
        pointer = SSTORE2.write(bytes(_text));
    }

    function html() external view returns (string memory html) {
        html = string.concat("<h1>", t, "</h1><div>", string(SSTORE2.read(pointer)), "</div>");
    }
}