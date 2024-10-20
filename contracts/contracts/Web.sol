// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "solady/src/auth/Ownable.sol";
import "solady/src/utils/LibString.sol";
import "./lib/Format.sol";
import "./Sculpture.sol";

interface IGarden {
    function getSculptures() external view returns (address[] memory);
    function topContributors(uint limit) external view returns (address[] memory, uint[] memory);
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

    function _html(string memory body) internal view returns (string memory) {
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
            ".i { margin: 0 0 5em; }",
            "</style>"
        );
        html = string.concat(html, "<body>", body, "</body></html>");
        return html;
    }

    function html() public view returns (string memory html) {
        address[] memory sculptures = IGarden(garden).getSculptures();
        html = string.concat(html,
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
            '<h2>', LibString.toHexString(garden), '</h2>',
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

        // Sculptures

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

        // Top10 Contributions
        (address[] memory topContributors, uint256[] memory topContributions) = IGarden(garden).topContributors(10);
        html = string.concat(html, '<div class="w"><div class="s">');
        html = string.concat(html, "<p>You may support this show by sending a donation directly to the show contract: ", LibString.toHexString(garden)  ,"</p>");
        html = string.concat(html, "<h2>Top Contributors</h2>");
        html = string.concat(html, '<ol class="cl">');
        for (uint256 i = 0; i < topContributors.length; i++) {
            html = string.concat(html, unicode'<li><span class="address">', LibString.toHexString(topContributors[i]), "</span> - ", Format.formatEther(topContributions[i]), " ETH</li>");
        }
        html = string.concat(html, "</ol>");
        html = string.concat(html, "</div></div>");

        html = string.concat(html, '<div class="i">Generated in block ', LibString.toString(block.number), /*" (", LibString.toString(block.timestamp), ")",*/ " from ", LibString.toHexString(address(this)) ,"</div>");
        html = string.concat(html, "</div>");

        // Resolve ENS
        html = string.concat(html,
            '<script type="module">',
            'import { ethers } from "https://cdn.jsdelivr.net/npm/ethers@6.13.4/+esm";',
            'const provider = new ethers.JsonRpcProvider("https://eth.drpc.org");',

            'const result = await Promise.all(',
                'Array.from(document.querySelectorAll(".address")).map(async (el) => {',
                'const address = el.textContent;',
                'if (!ethers.isAddress(address)) return address;',
                'const name = await provider.lookupAddress(address);',
                'if (name) el.textContent = name;',
                'return name || address;',
                '})',
            ');'
            '</script>'
        );

        return _html(html);
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