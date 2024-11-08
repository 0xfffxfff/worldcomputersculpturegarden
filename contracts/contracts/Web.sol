// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "solady/src/auth/Ownable.sol";
import "solady/src/utils/LibString.sol";
import "./lib/Web3url.sol";
import "./lib/Format.sol";
import "./Sculpture.sol";
import "./Essay.sol";

interface IGarden {
    function getSculptures() external view returns (address[] memory);
    function topContributors(uint limit) external view returns (address[] memory, uint[] memory);
}

interface IWeb is IDecentralizedApp {
    function html() external view returns (string memory);
}

contract Web is IWeb, Ownable {
    address public garden;
    address public renderer;

    constructor() {
        _initializeOwner(msg.sender);
    }

    function setRenderer(address _renderer) public onlyOwner {
        renderer = _renderer;
    }

    function html() external view returns (string memory) {
        return GardenRenderer(renderer).html();
    }

    function request(string[] memory resource, KeyValue[] memory params) external view returns (uint statusCode, string memory body, KeyValue[] memory headers) {
        return GardenRenderer(renderer).request(resource, params);
    }

    function resolveMode() external pure returns (bytes32) {
        return "5219";
    }

}

contract GardenRenderer is IWeb {

    address immutable public garden;
    address immutable public essayContract;

    constructor(address _garden, address _essayContract) {
        garden = _garden;
        essayContract = _essayContract;
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
            ".c.essay { max-width: 620px; }",
            "a { color: inherit; text-decoration: underline; }",
            ".w { position: relative; min-height: 100vh; display: flex; align-items: center; padding: 10em 0; }",
            ".s { width: 100%; max-width: 840px; }",
            ".s:not(.g) a { max-width: 100%; display: inline-block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }",
            ".t { max-width: 100%; overflow-x: auto; margin: 1em 0; }",
            ".i { margin: 0 0 5em; }",
            ".f { position: fixed; bottom: 1em; right: 1.3em; }",
            ".p { position: absolute; bottom: 2em; left: 50%; transform: translateX(-50%); }",
            "</style>"
        );
        html = string.concat(html, "<body>", body, "</body></html>");
        return html;
    }

    function html() public view returns (string memory) {
        return index();
    }

    function index() public view returns (string memory html) {
        address[] memory sculptures = IGarden(garden).getSculptures();
        html = string.concat(html,
            '<div class="c">',
            '<div class="w">',
            '<div class="s g">',
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
            '<h2>', LibString.toHexString(garden), '</h2>',
            '<br />',
            '<pre class="garden">',
            unicode"      ⚘                      ⚘\n",
            unicode"              ⚘\n",
            unicode" ⚘                     ⚘         ⚘\n",
            unicode"          ⚘      ⚘\n",
            unicode"     ⚘                     ⚘\n",
            unicode"</pre>",
            '<br />',
            '<p>',
            'A contract show curated by ',
            '<a href="https://0xfff.love" target="_blank" rel="noopener noreferrer">0xfff</a><br/>',
            'with special thanks to ',
            '<a href="https://x.com/sssluke1" target="_blank" rel="noopener noreferrer">sssluke</a> and <a href="https://x.com/0x113d" rel="noopener noreferrer" target="_blank">113</a>',
            '<br/><br/>',
            '<a href="/essay">Essay</a> by <a href="https://x.com/maltefr_eth" target="_blank" rel="noopener noreferrer">', Essay(essayContract).authors()[0] ,'</a>',
            "</p>",
            '<br /><br />'
        );
        html = string.concat(
            html,
            "<br />",
            "</div>",
            unicode'<div class="p">↓</div>',
            "</div>"
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

        // // Top10 Contributions
        // (address[] memory topContributors, uint256[] memory topContributions) = IGarden(garden).topContributors(10);
        // html = string.concat(html, '<div class="w"><div class="s">');
        // html = string.concat(html, unicode"<p>You may plant a ⚘ by sending 0.01 ETH to ", LibString.toHexString(garden)  ,"</p>");
        // html = string.concat(html, unicode"<h2>Most ⚘</h2>");
        // html = string.concat(html, '<ol class="cl">');
        // for (uint256 i = 0; i < topContributors.length; i++) {
        //     html = string.concat(html, unicode'<li><span class="address">', LibString.toHexString(topContributors[i]), unicode"</span> — ⚘ × ", LibString.toString(topContributions[i]/(0.01 ether)), "</li>");
        // }
        // html = string.concat(html, "</ol>");
        // html = string.concat(html, "</div></div>");


        html = string.concat(html, '<div class="i">Generated in block ', LibString.toString(block.number), /*" (", LibString.toString(block.timestamp), ")",*/ " from ", LibString.toHexString(address(this)) ,"</div>");
        html = string.concat(html, "</div>");

        // Resolve ENS
        html = string.concat(html,
            '<script type="module">',
            'import { JsonRpcProvider, isAddress } from "https://cdn.jsdelivr.net/npm/ethers@6.13.4/+esm";',
            'const provider = new JsonRpcProvider("https://eth.drpc.org");',

            'const result = await Promise.all(',
                'Array.from(document.querySelectorAll(".address")).map(async (el) => {',
                'const address = el.textContent;',
                'if (!isAddress(address)) return address;',
                'const name = await provider.lookupAddress(address);',
                'if (name) el.textContent = name;',
                'return name || address;',
                '})',
            ');'
            '</script>'
        );

        return _html(html);
    }

    function essay() public view returns (string memory html) {
        address[] memory sculptures = IGarden(garden).getSculptures();
        html = string.concat(html,
            '<div class="c essay"><div class="w"><div class="s g">',
                '<p><i>This text was published as part of the contract show: <a href="/" style="display: block">World Computer Sculpture Garden</a></i></p>',
                '<br/>',
                unicode'⚘',
                '<br/><br/><br/>',
                '<article>',
                Essay(essayContract).html(),
                '</article>',
                '<br/><br/>',
                unicode'⚘',
                '<br/><br/>',
                '<p><i>View the exhibition at: <a href="/" style="display: block">World Computer Sculpture Garden</a></i></p>',
                '<br/>',
            '</div></div></div>',
            unicode'<div class="f"><a href="/" style="text-decoration: none;">⚘</a></div>'
        );
        return _html(html);
    }

    function resolveMode() external pure returns (bytes32) {
        return "5219";
    }

    // ERC-5219
    function request(string[] memory resource, KeyValue[] memory params) external view returns (uint statusCode, string memory body, KeyValue[] memory headers) {
        // Index
        if(resource.length == 0) {
            body = index();
            statusCode = 200;
            headers = new KeyValue[](1);
            headers[0].key = "Content-Type";
            headers[0].value = "text/html; charset=utf-8";
            return (statusCode, body, headers);
        } else if (resource.length == 1 && keccak256(abi.encodePacked(resource[0])) == keccak256(abi.encodePacked("essay"))) {
            body = essay();
            statusCode = 200;
            headers = new KeyValue[](1);
            headers[0].key = "Content-Type";
            headers[0].value = "text/html; charset=utf-8";
            return (statusCode, body, headers);
        }

        statusCode = 404;
        return (statusCode, body, headers);
    }

    // Utility
    function stripURL(string memory url) internal pure returns (string memory) {
        bytes memory urlBytes = bytes(url);
        uint256 length = urlBytes.length;
        uint256 start = 0;
        uint256 end = length;

        // Handle "data:" URLs first
        if (length >= 5 && urlBytes[0] == "d" && urlBytes[1] == "a" && urlBytes[2] == "t" && urlBytes[3] == "a" && urlBytes[4] == ":") {
            // we want a shortened version of the data URL, that replaces everything after the first comma with "..."
            // e.g. "data:text/plain;base64,..."
            for (uint256 i = 5; i < length; i++) {
                if (urlBytes[i] == ",") {
                    end = i;
                    break;
                }
            }
        // Otherwise, handle other URLs
        } else {

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