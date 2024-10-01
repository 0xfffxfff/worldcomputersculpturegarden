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

interface IWeb {
    function html() external view returns (string memory);
}

contract Web is IWeb, Ownable {
    address public garden;
    address public renderer;

    constructor() {
        _initializeOwner(msg.sender);
    }

    function html() external view returns (string memory) {
        return GardenRenderer(renderer).html();
    }

    function setRenderer(address _renderer) public onlyOwner {
        renderer = _renderer;
    }
}

contract GardenRenderer {

    address immutable public garden;

    constructor(address _garden) {
        garden = _garden;
    }

    function html() public view returns (string memory) {
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
            "a { color: inherit; text-decoration: underline; }",
            ".s { margin: 5em 0; }",
            ".s a { text-decoration: none; max-width: 100%; display: inline-block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }",
            "pre { line-height: 1.3; font-size: 1.2rem;}",
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
            "<h1>", Sculpture(garden).title() ,"</h1>"
            '<br /><br />',
        '<p>',
        'A contract show organized by ',
        '<a href="https://0xfff.love" target="_blank" rel="noopener noreferrer">0xfff</a><br />with special thanks to ',
        '<a href="https://x.com/sssluke1" target="_blank" rel="noopener noreferrer">sssluke</a> and <a href="https://x.com/0x113d" rel="noopener noreferrer" target="_blank">113</a>',
        "</p>",
        "<br /><br />");

        address[] memory sculptures = IGarden(garden).getSculptures();
        for (uint256 i = 0; i < sculptures.length; i++) {
            Sculpture sculpture = Sculpture(sculptures[i]);
            string memory title = sculpture.title();
            html = string.concat(html, '<div class="s"');
            string[] memory authors = sculpture.authors();
            if (authors.length > 0) {
                html = string.concat(html, "<p>");
                for (uint256 j = 0; j < authors.length; j++) {
                    html = string.concat(html, authors[j], "<br/>");
                }
                html = string.concat(html, "</p>");
            }
            if (bytes(title).length > 0) {
                html = string.concat(html, "<h2><i>", title, "</i></h2>");
            } else {
                html = string.concat(html, "<h2><i>", "Untitled", "</i></h2>");
            }
            address[] memory addresses = sculpture.addresses();
            if (addresses.length > 0) {
                html = string.concat(html, "<p>");
                for (uint256 j = 0; j < addresses.length; j++) {
                    html = string.concat(html, LibString.toHexString(addresses[j]), "<br/>");
                }
                html = string.concat(html, "</p>");
            }
            string[] memory urls = sculpture.urls();
            if (urls.length > 0) {
                html = string.concat(html, "<p>");
                for (uint256 j = 0; j < urls.length; j++) {
                    html = string.concat(html, renderUrl(urls[j]), "<br/>");
                }
                html = string.concat(html, "</p>");
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

    function stripURL(string memory url) internal pure returns (string memory) {
        bytes memory urlBytes = bytes(url);
        uint256 length = urlBytes.length;
        uint256 start = 0;
        uint256 end = length;

        // Find the position of "://", which indicates the end of the protocol
        for (uint256 i = 0; i < length - 2; i++) {
            if (urlBytes[i] == ":" && urlBytes[i + 1] == "/" && urlBytes[i + 2] == "/") {
                start = i + 3; // Skip the "://"
                break;
            }
        }

        // Find position of "?" or "#" to determine the end of the main URL
        for (uint256 i = start; i < length; i++) {
            if (urlBytes[i] == "?" || urlBytes[i] == "#") {
                end = i;
                break;
            }
        }

        // Remove trailing slash if present
        if (end > start && urlBytes[end - 1] == "/") {
            end -= 1;
        }

        // Create a new byte array to store the stripped URL
        bytes memory strippedUrlBytes = new bytes(end - start);
        for (uint256 i = start; i < end; i++) {
            strippedUrlBytes[i - start] = urlBytes[i];
        }

        return string(strippedUrlBytes);
    }

    function renderUrl(string memory url) internal pure returns (string memory) {
        string memory strippedUrl = stripURL(url);
        return string.concat('<a href="', url, '" target="_blank" rel="noopener noreferrer">', strippedUrl ,'</a>');
    }


}