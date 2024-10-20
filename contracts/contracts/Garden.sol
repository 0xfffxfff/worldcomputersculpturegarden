// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import "solady/src/auth/Ownable.sol";
import "./Sculpture.sol";
import "./Web.sol";
import "./s/impl/ST.sol";

contract Garden is Sculpture, ST {

    address[] public sculptures;

    address public immutable render;

    ///////////////////////////////////////////////////////////////////////////
    // Init
    ///////////////////////////////////////////////////////////////////////////

    constructor(address[] memory _sculptures, address _render, address _sp) ST(_sp, msg.sender) {
        sculptures = _sculptures;
        render = _render;
    }

    ///////////////////////////////////////////////////////////////////////////
    // Web
    ///////////////////////////////////////////////////////////////////////////

    fallback() external payable {
        revert(IWeb(render).html());
    }

    function html() external view returns (string memory) {
        return IWeb(render).html();
    }

    ///////////////////////////////////////////////////////////////////////////
    // Sculpture Management
    ///////////////////////////////////////////////////////////////////////////

    function getSculptures() public view returns (address[] memory) {
        return sculptures;
    }

    function setSculptures(address[] memory _sculptures) public onlyOwner {
        sculptures = _sculptures;
    }

    ///////////////////////////////////////////////////////////////////////////
    // Show
    ///////////////////////////////////////////////////////////////////////////

    function title() external pure returns (string memory) {
        return "World Computer Sculpture Garden";
    }

    function authors() external view returns (string[] memory) {
        uint256 length;
        for (uint256 i = 0; i < sculptures.length; i++) {
            string[] memory sculptureAuthors = Sculpture(sculptures[i]).authors();
            for (uint256 j = 0; j < sculptureAuthors.length; j++) {
                length++;
            }
        }
        string[] memory authors_ = new string[](length);
        uint256 index;
        for (uint256 i = 0; i < sculptures.length; i++) {
            string[] memory sculptureAuthors = Sculpture(sculptures[i]).authors();
            for (uint256 j = 0; j < sculptureAuthors.length; j++) {
                authors_[index] = sculptureAuthors[j];
                index++;
            }
        }
        return authors_;
    }

    function addresses() external view returns (address[] memory) {
        address[] memory addresses_;
        for (uint256 i = 0; i < sculptures.length; i++) {
            Sculpture sculpture = Sculpture(sculptures[i]);
            address[] memory sculptureAddresses = sculpture.addresses();
            for (uint256 j = 0; j < sculptureAddresses.length; j++) {
                addresses_[addresses_.length] = sculpture.addresses()[j];
            }
        }
        return addresses_;
    }

    string public exhibitionText;
    function text() public view returns (string memory) {
        return exhibitionText;
    }
    function setText(string memory _text) public onlyOwner {
        exhibitionText = _text;
    }

    string[] public exhibitionUrls;
    function setExhibitionUrls(string[] memory _urls) public onlyOwner {
        exhibitionUrls = _urls;
    }
    function urls() public view returns (string[] memory) {
        return exhibitionUrls;
    }
}