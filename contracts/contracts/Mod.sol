// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "solady/src/utils/SSTORE2.sol";

contract Mod is Ownable {

    constructor () Ownable(msg.sender) {}

    // Show Text
    address private exhibitionText;

    function setText(string memory _text) public onlyOwner {
        exhibitionText = SSTORE2.write(bytes(_text));
    }

    function text() public view returns (string memory) {
        if (exhibitionText == address(0)) {
            return "";
        }
        return string(SSTORE2.read(exhibitionText));
    }

    // Show URLs
    string[] private exhibitionUrls;

    function setExhibitionUrls(string[] memory _urls) public onlyOwner {
        exhibitionUrls = _urls;
    }

    function urls() public view returns (string[] memory) {
        return exhibitionUrls;
    }

    // fff
    string public fff = "0xfff";

    function setFff(string memory _fff) public onlyOwner {
        fff = _fff;
    }

    string public fffUrl = "https://www.0xfff.love";

    function setFffUrl(string memory _fffUrl) public onlyOwner {
        fffUrl = _fffUrl;
    }

    // 113
    string public oneOneThree = "113";

    function setOneOneThree(string memory _oneOneThree) public onlyOwner {
        oneOneThree = _oneOneThree;
    }

    string public oneOneThreeUrl = "https://x.com/0x113d";

    function setOneOneThreeUrl(string memory _oneOneThreeUrl) public onlyOwner {
        oneOneThreeUrl = _oneOneThreeUrl;
    }

    // Luke
    string public luke = "sssluke";

    function setLuke(string memory _luke) public onlyOwner {
        luke = _luke;
    }

    string public lukeUrl = "https://x.com/sssluke1";

    function setLukeUrl(string memory _lukeUrl) public onlyOwner {
        lukeUrl = _lukeUrl;
    }

    // Malte
    string public malte = "maltefr";

    function setMalte(string memory _malte) public onlyOwner {
        malte = _malte;
    }

    string public malteUrl = "https://x.com/maltefr_eth";

    function setMalteUrl(string memory _malteUrl) public onlyOwner {
        malteUrl = _malteUrl;
    }
}