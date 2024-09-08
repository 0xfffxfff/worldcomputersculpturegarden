// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "solady/src/auth/Ownable.sol";
import "solady/src/utils/LibString.sol";
import "./Sculpture.sol";

interface IGarden {
    function getContribution(uint256 index) external view returns (address contributor, uint256 amount);
    function getContributed() external view returns (uint256);
    function getSculptures() external view returns (address[] memory);
}

contract Web {

    address immutable public garden;

    constructor(address _garden) {
        garden = _garden;
    }

    function content() public view returns (string memory) {
        string memory html = "<html>";
        html = string.concat(html,
            "<style>"
            '*, *::before, *::after { box-sizing: border-box; }',
            'html { -moz-text-size-adjust: none; -webkit-text-size-adjust: none; text-size-adjust: none; }',
            'html { margin: 0; padding: 0; } body { min-height: 100vh }',
            'html,body,pre { font-family: "Courier New", "Courier", monospace; font-size: 15px; }',
            'h1,h2,h3 { margin: 0; font-size: inherit; font-style: inherit; font-weight: inherit;}',
            ".c { max-width: 590px; margin: 5em auto; }",
            "@media screen and (max-width: 760px) { .c { margin: 2.5em auto; } }",
            ".s { margin: 5em 0 5em; }",
            "</style>"
        );
        html = string.concat(
            html, "<body>",
            '<div class="c">',
            "<pre>",
unicode"     ⚘\n",
unicode"              ⚘         ⚘\n",
unicode"        ⚘\n",
unicode"                     ⚘     ⚘\n",
unicode"      ⚘        ⚘\n",
unicode"                       ⚘\n",
unicode"            ⚘\n",
unicode"          </pre>",
            "<br><br>",
            "<h1>", Sculpture(garden).title() ,"</h1>");
            // "<p>", Sculpture(garden).text(), "</p>"

        address[] memory sculptures = IGarden(garden).getSculptures();
        for (uint256 i = 0; i < sculptures.length; i++) {
            Sculpture sculpture = Sculpture(sculptures[i]);
            string memory title = sculpture.title();
            html = string.concat(html, '<div class="s"');
            string[] memory authors = sculpture.authors();
            for (uint256 j = 0; j < authors.length; j++) {
                html = string.concat(html, "<p>", authors[j], "</p>");
            }
            if (bytes(title).length > 0) {
                html = string.concat(html, "<h2><i>", title, "</i></h2>");
            } else {
                html = string.concat(html, "<h2><i>", "Untitled", "</i></h2>");
            }
            address[] memory addresses = sculpture.addresses();
            for (uint256 j = 0; j < addresses.length; j++) {
                html = string.concat(html, "<p>", LibString.toHexString(addresses[j]), "</p>");
            }
            string memory text = sculpture.text();
            if (bytes(text).length > 0) {
                html = string.concat(html, "<p>", text, "</p>");
            }
            html = string.concat(html, "</div>");
        }
        // uint contributed = GardenContributions(garden).getContributed();
        // for (uint256 i = 0; i < contributed; i++) {
        //     html = string(abi.encodePacked(html, "<li>", GardenContributions(garden).getContribution(i), "</li>"));
        // }
        html = string.concat(html, "<br><br><p>Generated at block ", LibString.toString(block.number), " (", LibString.toString(block.timestamp), ")</p>");
        html = string.concat(html, "</div></body></html>");
        return html;
    }

}