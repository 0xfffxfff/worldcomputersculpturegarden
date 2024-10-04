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
        address[] memory sculptures = IGarden(garden).getSculptures();

        string memory html = "<html>";
        html = string.concat(html,
            '<head>',
            '<meta charset="UTF-8">',
            '<meta name="viewport" content="width=device-width, initial-scale=1.0">',
            '<title>', Sculpture(garden).title() ,'</title>',
            '</head>',
            "<style>",
            '*, *::before, *::after { box-sizing: border-box; }',
            'html { -moz-text-size-adjust: none; -webkit-text-size-adjust: none; text-size-adjust: none; }',
            'html, body { margin: 0; padding: 0; } body { min-height: 100vh }',
            'html,body,pre { font-family: "Courier New", "Courier", monospace; font-size: 15px; }',
            'h1,h2,h3 { margin: 0; font-size: inherit; font-style: inherit; font-weight: inherit;}',
            ".c { max-width: 840px; margin: 0 auto; padding: 0 1.5em; box-sizing: content-box; }",
            "a { color: inherit; text-decoration: underline; }",
            ".w { min-height: 100vh; display: flex; align-items: center; padding: 10em 0; }",
            ".s { width: 100%; max-width: 840px; }",
            ".s:not(.g) a { max-width: 100%; display: inline-block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }",
            ".t { max-width: 100%; overflow-x: auto; margin: 1em 0; }",
            ".i { margin: 50vh 0 5em; }",
            "</style>"
        );
        html = string.concat(
            html, "<body>",
            '<div class="c">',
            '<div class="w"><div class="s g">',
            '<pre class="garden">',
            unicode"       ⚘                    ⚘\n",
            unicode"             ⚘\n",
            unicode"⚘                       ⚘         ⚘\n",
            unicode"        ⚘         ⚘\n",
            unicode"   ⚘                          ⚘\n",
            unicode"</pre>",
            '<br /><br />',
            unicode"<h1>", Sculpture(garden).title(), "</h1>\n",
            '<br /><br />'
        );
        for (uint256 i = 0; i < sculptures.length; i++) {
            string[] memory authors = Sculpture(sculptures[i]).authors();
            // Temporary: For now we just use the first author here
            if (authors.length > 0) {
                html = string.concat(html, authors[0], "<br/>");
            }
        }
        html = string.concat(html,
            '<br /><br />',
            '<pre class="garden">',
            unicode"      ⚘                      ⚘\n",
            unicode"              ⚘\n",
            unicode" ⚘                     ⚘         ⚘\n",
            unicode"          ⚘      ⚘\n",
            unicode"     ⚘                     ⚘\n",
            unicode"</pre>",
            '<br />',
            '<p>',
            'A contract show organized by ',
            '<a href="https://0xfff.love" target="_blank" rel="noopener noreferrer">0xfff</a><br />',
            'with special thanks to ',
            '<a href="https://x.com/sssluke1" target="_blank" rel="noopener noreferrer">sssluke</a> and <a href="https://x.com/0x113d" rel="noopener noreferrer" target="_blank">113</a>',
            "</p>",
            '<br /><br />'
        );

        html = string.concat(
            html,
            "<br />",
            "</div></div>"
        );

        for (uint256 i = 0; i < sculptures.length; i++) {
            Sculpture sculpture = Sculpture(sculptures[i]);
            string memory title = sculpture.title();
            html = string.concat(html, '<div class="w"><div class="s">');
            string[] memory authors = sculpture.authors();
            if (authors.length > 0) {
                html = string.concat(html, "<h2>");
                for (uint256 j = 0; j < authors.length; j++) {
                    if (bytes(authors[j]).length == 0) continue; // ignore empty
                    html = string.concat(html, authors[j], "<br/>");
                }
                html = string.concat(html, "</h2>");
            }
            if (bytes(title).length > 0) {
                html = string.concat(html, "<h3><i>", title, "</i></h3>");
            } else {
                html = string.concat(html, "<h3><i>", "Untitled", "</i></h3>");
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
                    if (bytes(urls[j]).length == 0) continue; // ignore empty
                    html = string.concat(html, renderUrl(urls[j]), "<br/>");
                }
                html = string.concat(html, "</p>");
            }
            string memory text = sculpture.text();
            if (bytes(text).length > 0) {
                html = string.concat(html, '<div class="t">', text, '</div>');
            }
            html = string.concat(html, "</div></div>");
        }
        // uint contributed = GardenContributions(garden).getContributed();
        // for (uint256 i = 0; i < contributed; i++) {
        //     html = string(abi.encodePacked(html, "<li>", GardenContributions(garden).getContribution(i), "</li>"));
        // }
        html = string.concat(html, '<div class="i">Generated at block ', LibString.toString(block.number), " (", LibString.toString(block.timestamp), ")</div>");
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
                start = i + 3; // Skip the "://"max
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