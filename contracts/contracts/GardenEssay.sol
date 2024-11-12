// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solady/src/utils/LibString.sol";
import "./GardenHTML.sol";
import "./IGarden.sol";
import "./Essay.sol";
import "./Sculpture.sol";

library GardenEssay {
    function html(address garden, address essayContract) public view returns (string memory html) {
        html = string.concat(html,
            '<div class="c essay"><div class="w"><div class="s g">',
                '<p><i>This text was published as part of the contract show: <a href="/" style="display: block">', Sculpture(garden).title() ,'</a></i></p>',
                '<br><br><br>',
                unicode'⚘',
                '<br><br><br><br>',
                '<article>',
                Essay(essayContract).html(),
                '</article>',
                '<br><br><br><br>',
                unicode'⚘',
                '<br><br><br>',
                '<p><span class="a">', LibString.toHexStringChecksummed(garden),'</span></p>',
                '<br><br>',
                '<p><i>This text was published as part of the show <a href="/" style="display: block">', Sculpture(garden).title() ,'</a></i></p>',
                '<br>',
            '</div></div></div>',
            unicode'<div class="f"><a href="/" style="text-decoration: none;">⚘</a></div>'
        );

        string memory description = string.concat(
            'The essay "', Essay(essayContract).title(),
            '" written by ', Essay(essayContract).authors()[0] ,
            ' was published as part of the contract show: ', Sculpture(garden).title());

        return GardenHTML.html(html, Sculpture(garden).title(), description);
    }
}