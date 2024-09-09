// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "../Sculpture.sol";

contract ExampleSculptureStaticLongUrl is Sculpture {

    function title() external pure override returns (string memory) {
        return "Static Example With Long URL";
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
        return "This is an example sculpture that is static and has a long url";
    }

    function urls() public view override returns (string[] memory urls) {
        urls = new string[](3);
        urls[0] = "https://thisisaverylongsubdomainthatdoesnotexist.0xfff.love/this/is/a/very/long/url/?with=query&params=that&are=long&and=have&many=characters&and=numbers=1234567890#and-also-a-fragment";
        urls[1] = "https://shortdomainbutlonghashtag.0xfff.love/#this-is-a-very-long-fragment-that-is-very-long-and-has-many-characters-and-numbers-1234567890";
        urls[2] = "https://shortonebutlongquery.0xfff.love/?this=is=a&very=long&query=that&has=many&characters=and&numbers=1234567890";
    }
}