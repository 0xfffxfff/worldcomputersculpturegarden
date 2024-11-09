// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "solady/src/utils/LibString.sol";
import "./GardenHTML.sol";
import "../IGarden.sol";
import "../Essay.sol";
import "../Sculpture.sol";

library GardenEssay {
    function html(address garden, address essayContract) public view returns (string memory html) {
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
        return GardenHTML.html(html, Sculpture(garden).title());
    }
}