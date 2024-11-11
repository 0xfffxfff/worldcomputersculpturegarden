// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "solady/src/auth/Ownable.sol";
import "solady/src/utils/SSTORE2.sol";
import "./Sculpture.sol";

contract Essay is Sculpture, Ownable {

    address private pointer1;
    address private pointer2;
    string private t;
    string private a = "maltefr";
    string[] private u;

    constructor () {
        _initializeOwner(msg.sender);
    }

    function title() external view returns (string memory) {
        return t;
    }

    function authors() public view returns (string[] memory authors_) {
        authors_ = new string[](1);
        authors_[0] = a;
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
        if (pointer1 == address(0)) {
            return "";
        }
        return string.concat(
            string(SSTORE2.read(pointer1)),
            pointer2 == address(0) ? "" : string(SSTORE2.read(pointer2))
        );
    }

    function setTitle(string memory _title) external onlyOwner {
        t = _title;
    }

    function setAuthor(string memory _author) external onlyOwner {
        a = _author;
    }

    function setUrls(string[] memory _urls) external onlyOwner {
        u = _urls;
    }

    function setTextPt1(string memory _text) external onlyOwner {
        pointer1 = SSTORE2.write(bytes(_text));
    }

    function setTextPt2(string memory _text) external onlyOwner {
        pointer2 = SSTORE2.write(bytes(_text));
    }

    function html() external view returns (string memory html) {
        html = string.concat(
            "<h1>", t, "</h1>",
            "<br/><br/><br/>",
            "<h2><i>Written by ", authors()[0], "</i></h2>",
            "<br/><br/>",
            "<div>",
                pointer1 == address(0)
                    ? ""
                    : string.concat(
                        string(SSTORE2.read(pointer1)),
                        pointer2 == address(0) ? "" : string(SSTORE2.read(pointer2))
                    ),
            "</div>");
    }
}