// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solady/src/utils/LibString.sol";
import "./GardenHTML.sol";
import "./GardenContributions.sol";
import "./lib/Format.sol";
import "./Essay.sol";
import "./IGarden.sol";
import "./Sculpture.sol";
import "./Mod.sol";

library GardenIndex {
    function html(address garden, address essayContract, address data) public view returns (string memory html) {
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
            '<br><br>',
            unicode"<h1>", Sculpture(garden).title(), "</h1>\n",
            '<br><br>'
        );

        // Artist names
        for (uint256 i = 0; i < sculptures.length; i++) {
            try Sculpture(sculptures[i]).authors() returns (string[] memory authors) {
                for (uint256 j = 0; j < authors.length; j++) {
                    if (bytes(authors[j]).length == 0) continue; // ignore empty
                    html = string.concat(html, authors[j], "<br>");
                }
            } catch {
                html = string.concat(html, "Unkown<br>");
            }
        }

        // Header End
        html = string.concat(html,
            '<br><br>',
            '<h2 class="a">', LibString.toHexStringChecksummed(garden), '</h2><br><br>',
            '<pre class="garden">',
            unicode'      ⚘                      ⚘\n',
            unicode'              ⚘\n',
            unicode' ⚘                     ⚘         ⚘\n',
            unicode'          ⚘      ⚘\n',
            unicode'     ⚘                     ⚘\n',
            unicode'</pre><br>',
            '<p>',
            'A contract show curated by ',
            '<a href="', Mod(data).fffUrl() ,'" target="_blank" rel="noopener noreferrer">', Mod(data).fff(), '</a><br>',
            'with special thanks to ',
            '<a href="', Mod(data).lukeUrl(), '" target="_blank" rel="noopener noreferrer">', Mod(data).luke() ,'</a> and ',
            '<a href="', Mod(data).oneOneThreeUrl(), '" rel="noopener noreferrer" target="_blank">', Mod(data).oneOneThree(),'</a>',
            '<br><br>',
            '<a href="/essay">', Sculpture(essayContract).title() ,'</a> by <a href="', Mod(data).malteUrl(), '" target="_blank" rel="noopener noreferrer">', Mod(data).malte() ,'</a>',
            '</p><br><br>'
        );

        // Scroll Indicator
        html = string.concat(
            html,
            '<br></div>',
            unicode'<div class="p">↓</div></div>'
        );

        // Text
        html = string.concat(html,
            '<div class="w"><div class="s">',
            Sculpture(garden).text(),
            '<br>',
            '<p>The website you are viewing was generated from the show contract itself at block ', LibString.toString(block.number) ,'. ',
            'Over time, as people engage with the artworks and artists activate their pieces, the information rendered here will change. Block by block. Year by year.</p>',
            '</div></div>'
        );

        // Sculptures
        for (uint256 i = 0; i < sculptures.length; i++) {
            Sculpture sculpture = Sculpture(sculptures[i]);

            html = string.concat(html, '<div class="w"><div class="s">');

            // Authors
            try sculpture.authors() returns (string[] memory authors) {
                if (authors.length > 0) {
                    html = string.concat(html, '<h2>');
                    for (uint256 j = 0; j < authors.length; j++) {
                        if (bytes(authors[j]).length == 0) continue; // ignore empty
                        html = string.concat(html, authors[j], '<br>');
                    }
                    html = string.concat(html, '</h2>');
                }
            } catch {
                html = string.concat(html, '<h2><i>Unkown</i></h2>');
            }

            // Title
            try sculpture.title() returns (string memory title) {
                if (bytes(title).length > 0) {
                    html = string.concat(html, '<h3><i>', title, '</i></h3>');
                } else {
                    html = string.concat(html, '<h3><i>Untitled</i></h3>');
                }
            } catch {
                html = string.concat(html, '<h3><i>Untitled</i></h3>');
            }

            // Addresses
            try sculpture.addresses() returns (address[] memory addresses) {
                if (addresses.length > 0) {
                    html = string.concat(html, '<p>');
                    for (uint256 j = 0; j < addresses.length; j++) {
                        html = string.concat(html, '<span class="a">', LibString.toHexStringChecksummed(addresses[j]), '</span><br>');
                    }
                    html = string.concat(html, '</p>');
                }
            } catch {
                html = string.concat(html, '<p><span class="a">', LibString.toHexStringChecksummed(sculptures[i]) , '</span></p>');
            }

            // Urls
            try sculpture.urls() returns (string[] memory urls) {
                if (urls.length > 0) {
                    html = string.concat(html, '<p>');
                    for (uint256 j = 0; j < urls.length; j++) {
                        if (bytes(urls[j]).length == 0) continue; // ignore empty
                        html = string.concat(html, Format.renderUrl(urls[j]), '<br>');
                    }
                    html = string.concat(html, '</p>');
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

            html = string.concat(html, '</div></div>');
        }

        // Contributions
        html = string.concat(html, GardenContributions.html(garden));

        // Footer
        html = string.concat(html, '<div class="i">Generated in block ', LibString.toString(block.number), ' from <span class="a">', LibString.toHexStringChecksummed(address(this)) ,"</span></div>");

        // End
        html = string.concat(html, '</div>');

        string memory description = string.concat('Contract Show: World Computer Sculpture Garden at ', LibString.toHexStringChecksummed(garden), '. Curated by ', Mod(data).fff(), '.');

        return GardenHTML.html(html, Sculpture(garden).title(), description);
    }
}