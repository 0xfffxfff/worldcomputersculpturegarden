// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "solady/src/utils/LibString.sol";
import "./GardenHTML.sol";
import "./lib/Format.sol";
import "../Essay.sol";
import "../IGarden.sol";
import "../Sculpture.sol";

library GardenIndex {
    function html(address garden, address essayContract) public view returns (string memory html) {
        address[] memory sculptures = IGarden(garden).getSculptures();

        // Header
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

        // Artist names
        for (uint256 i = 0; i < sculptures.length; i++) {
            try Sculpture(sculptures[i]).authors() returns (string[] memory authors) {
                // Temporary: For now we just use the first author here
                if (authors.length > 0) {
                    html = string.concat(html, authors[0], "<br/>");
                }
            } catch {
                html = string.concat(html, "Missing<br/>");
            }
        }

        // Header End
        html = string.concat(html,
            '<br /><br />',
            '<h2 class="a">', LibString.toHexString(garden), '</h2><br />',
            '<pre class="garden">',
            unicode"      ⚘                      ⚘\n",
            unicode"              ⚘\n",
            unicode" ⚘                     ⚘         ⚘\n",
            unicode"          ⚘      ⚘\n",
            unicode"     ⚘                     ⚘\n",
            unicode"</pre><br />",
            '<p>',
            'A contract show curated by ',
            '<a href="https://0xfff.love" target="_blank" rel="noopener noreferrer">0xfff</a><br/>',
            'with special thanks to ',
            '<a href="https://x.com/sssluke1" target="_blank" rel="noopener noreferrer">sssluke</a> and <a href="https://x.com/0x113d" rel="noopener noreferrer" target="_blank">113</a>',
            '<br/><br/>',
            '<a href="/essay">Essay</a> by <a href="https://x.com/maltefr_eth" target="_blank" rel="noopener noreferrer">', Essay(essayContract).authors()[0] ,'</a>',
            "</p><br /><br />"
        );

        // Scroll Indicator
        html = string.concat(
            html,
            "<br /></div>",
            unicode'<div class="p">↓</div></div>'
        );

        // Text
        html = string.concat(html,
            '<div class="w"><div class="s"><p>',
                Sculpture(garden).text(),
                '<br/><br/> - 0xfff',
            '</p></div></div>'
        );

        // Sculptures
        for (uint256 i = 0; i < sculptures.length; i++) {
            Sculpture sculpture = Sculpture(sculptures[i]);

            html = string.concat(html, '<div class="w"><div class="s">');

            // Authors
            try sculpture.authors() returns (string[] memory authors) {
                if (authors.length > 0) {
                    html = string.concat(html, "<h2>");
                    for (uint256 j = 0; j < authors.length; j++) {
                        if (bytes(authors[j]).length == 0) continue; // ignore empty
                        html = string.concat(html, authors[j], "<br/>");
                    }
                    html = string.concat(html, "</h2>");
                }
            } catch {
                html = string.concat(html, "<h2><i>Missing</i></h2>");
            }

            // Title
            try sculpture.title() returns (string memory title) {
                if (bytes(title).length > 0) {
                    html = string.concat(html, "<h3><i>", title, "</i></h3>");
                } else {
                    html = string.concat(html, "<h3><i>Untitled</i></h3>");
                }
            } catch {
                html = string.concat(html, "<h3><i>Untitled</i></h3>");
            }

            // Addresses
            try sculpture.addresses() returns (address[] memory addresses) {
                if (addresses.length > 0) {
                    html = string.concat(html, "<p>");
                    for (uint256 j = 0; j < addresses.length; j++) {
                        html = string.concat(html, '<span class="a">', LibString.toHexString(addresses[j]), "</span><br/>");
                    }
                    html = string.concat(html, "</p>");
                }
            } catch {
                html = string.concat(html, "<p><span class='a'>", LibString.toHexString(sculptures[i]) , "</span></p>");
            }

            // Urls
            try sculpture.urls() returns (string[] memory urls) {
                if (urls.length > 0) {
                    html = string.concat(html, "<p>");
                    for (uint256 j = 0; j < urls.length; j++) {
                        if (bytes(urls[j]).length == 0) continue; // ignore empty
                        html = string.concat(html, Format.renderUrl(urls[j]), "<br/>");
                    }
                    html = string.concat(html, "</p>");
                }
            } catch {
                // ignore reverting urls
            }

            // Text
            try sculpture.text() returns (string memory text) {
                if (bytes(text).length > 0) {
                    html = string.concat(html, '<div class="t">', text, '</div>');
                }
            } catch {
                html = string.concat(html, '<div class="t"><i>Contract Reverted</i></div>');
            }

            html = string.concat(html, "</div></div>");
        }

        // Contributions
        html = string.concat(html,
            '<div class="w"><div class="s">',
                '<div id="field1" class="field"></div>'
                '<br/><br/><br/>',
                '<p style="text-align:center;">',
                'Guestbook',
                '<br/><br/>',
                'You may leave a flower here by sending 0.01 ETH (or multiples thereof)<br/> to the show contract at <span class="a">',
                    LibString.toHexString(garden),
                '</span><br/><br/>',
                LibString.toString(IGarden(garden).guests() + 5 /* DEV TODO */),
                ' guests have planted ', LibString.toString(IGarden(garden).flowers() + 200 /* DEV TODO */),
                ' flowers',
                '</p><br/><br/><br/>',
                '<div id="field2" class="field"></div>',
                '<script>',
                    '(() => {',
                    'const flowers = ', LibString.toString(IGarden(garden).flowers() + 200 /* DEV TODO */), ';'
                    'function calculateThreshold(planted) {',
                        'const min = 30, max = 3000, lower = 0.99, higher = 0.6;',
                        'if (planted <= min) return lower;',
                        'if (planted >= max) return higher;',
                        'const normalized = (planted - min) / (max - min);',
                        'const logValue = Math.log10(1 + normalized * (10 - 1));',
                        'return higher + (lower - higher) * (1 - logValue);',
                    '}',
                    'function isConditionMet(planted, val) {',
                        'const threshold = calculateThreshold(planted);',
                        'return val > threshold || val < -threshold;',
                    '}',
                    'function gridNoise(x, z, seed) {',
                    '    var n = (1619 * x + 31337 * z + 1013 * seed) & 0x7fffffff;',
                    '    n = BigInt((n >> 13) ^ n);',
                    '    n = n * (n * n * 60493n + 19990303n) + 1376312589n;',
                    '    n = parseInt(n.toString(2).slice(-31), 2);',
                    '    return 1 - n / 1073741824;',
                    '}',
                    'const width = 90;',
                    'let lines = [""], counter = 0, planted = 0;',
                    'while (planted < flowers) {',
                    '    const val = gridNoise(counter % width, Math.floor(counter / width), 0xf);',
                    '    if ('
                                'isConditionMet(planted, val)',

                        ') {',
                    unicode'        lines[Math.floor(counter / width)] += `<a href="#${planted+1}" data-flower-id="${planted+1}">⚘</a>`;',
                                    'planted++;',
                    '    } else { lines[Math.floor(counter / width)] += " "; }',
                    '    if (counter % width == (width-1) && planted < flowers) { lines.push(""); }',
                    '    counter++;'
                    '}',
                    'lines = lines.reduce((acc, line) => { if (line.trim().length > 0) acc.push(line); return acc; }, []);',
                    'document.querySelector("#field1").innerHTML = lines.slice(0,Math.min(7,Math.ceil(lines.length/2))).join("\\n");',
                    'document.querySelector("#field2").innerHTML = lines.slice(Math.min(7,Math.ceil(lines.length/2))).join("\\n");',
                    'document.querySelectorAll(".field").forEach((el) => el.addEventListener("click", (e) => {',
                    '    const flowerId = e.target.dataset.flowerId;',
                    '    if (flowerId) {',
                    '        e.preventDefault();'
                    // '        console.log("Flower #" + flowerId);',
                            // TODO: Tooltip
                    '    }',
                    '}));',
                    '})();/*IIFE*/',
                '</script>',
            '</div></div>'
        );

        // Footer
        html = string.concat(html, '<div class="i">Generated in block ', LibString.toString(block.number), /*" (", LibString.toString(block.timestamp), ")",*/ ' from <span class="a">', LibString.toHexString(address(this)) ,"<span></div>");
        html = string.concat(html, "</div>");

        // Script: Resolve ENS
        // html = string.concat(html,
        //     '<script type="module">',
        //     'import { JsonRpcProvider, isAddress } from "https://cdn.jsdelivr.net/npm/ethers@6.13.4/+esm";',
        //     'const provider = new JsonRpcProvider("https://eth.drpc.org");',

        //     'const result = await Promise.all(',
        //         'Array.from(document.querySelectorAll(".address")).map(async (el) => {',
        //         'const address = el.textContent;',
        //         'if (!isAddress(address)) return address;',
        //         'const name = await provider.lookupAddress(address);',
        //         'if (name) el.textContent = name;',
        //         'return name || address;',
        //         '})',
        //     ');'
        //     '</script>'
        // );

        return GardenHTML.html(html, Sculpture(garden).title());
    }
}