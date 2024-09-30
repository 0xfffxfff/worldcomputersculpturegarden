// SPDX-License-Identifier: MIT
// Show Critique.
// By Rhea Myers.
// Copyright 2024 Myers Studio Ltd.
pragma solidity >=0.8.0;

import "solady/src/auth/Ownable.sol";
import "solady/src/utils/LibString.sol";
import "./Sculpture.sol";
import "./Garden.sol";

contract ShowCritique is Sculpture, Ownable {

    struct Critique {
        address critic;
        uint8 critique;
    }

    uint256 private constant OPINIONS_COUNT = 16;

    string[OPINIONS_COUNT] private OPINIONS = [
        "totally awesome",
        "entirely excellent",
        "transcendently fascinating",
        "completely intriguing",
        "deeply moving",
        "profoundly affecting",
        "groundbreaking",
        "so cute",
        "totes adorbs",
        "strikingly profound",
        "triumphantly skilful",
        "a revelation",
        "unignorably brilliant",
        "thought provoking",
        "intellectually stimulating",
        "visually stimulating"
    ];

    mapping(address => Critique) private critiques;
    address payable private gardenAddress;

    constructor () {
        _initializeOwner(msg.sender);
    }

    function configure (address payable newGardenAddress) external onlyOwner {
        gardenAddress = newGardenAddress;
        Garden garden = Garden(gardenAddress);
        address critic = msg.sender;
        address[] memory works = garden.getSculptures();
        for (uint256 i = 0; i < works.length; i++) {
            if (critiques[works[i]].critic == address(0x0)) {
                critiques[works[i]] = Critique(
                    critic,
                    uint8(i % OPINIONS_COUNT)
                );
            }
        }
    }

    function critiqueWork (uint256 workIndex, address workAddress, uint8 critique) external {
        Garden garden = Garden(gardenAddress);
        require(
            garden.getSculptures()[workIndex] == workAddress,
            "invalid work (was the garden changed?)"
        );
        require(
            critique < OPINIONS_COUNT,
            "invalid critical opinion (indices start at zero)"
        );
        critiques[workAddress] = Critique(
            msg.sender,
            critique
        );
    }

    function formatOpinion (address workAddress) internal view returns (string memory) {
        Sculpture work = Sculpture(workAddress);
        Critique memory critique = critiques[workAddress];
        return string.concat(
            "<p>",
            LibString.toHexStringChecksummed(critique.critic),
            " thinks that <i><span style=\"white-space: nowrap;\">",
            work.title(),
            "</span></i> <span style=\"white-space: nowrap;\">by ",
            work.authors()[0],
            "</span> is <span style=\"white-space: nowrap;\">",
            OPINIONS[critique.critique],
            ".</span></p>\n"
        );
    }

    function formatOpinions () internal view returns (string memory) {
        Garden garden = Garden(gardenAddress);
        address[] memory sculptureAddresses = garden.getSculptures();
        string memory opinions = "";
        for (uint256 i = 0; i < sculptureAddresses.length; i++) {
            address workAddress = sculptureAddresses[i];
            Critique storage critique = critiques[workAddress];
            if (critique.critic != address(0x0))
                opinions = string.concat(
                    opinions,
                    formatOpinion(workAddress)
                );
        }
        return opinions;
    }

    function title() external view override returns (string memory) {
        // This title is dynamic and always shows the current block timestamp
        return string.concat("Critique of This Show");
    }

    function authors() external view override returns (string[] memory) {
        string[] memory authors_ = new string[](1);
        authors_[0] = "Rhea Myers et al.";
        return authors_;
    }

    function addresses() external view override returns (address[] memory) {
        address[] memory addresses_ = new address[](1);
        // this too, could be dynamic or change over time
        addresses_[0] = address(this);
        return addresses_;
    }

    function text() public view override returns (string memory) {
        return formatOpinions();
    }

    function urls() public view override returns (string[] memory) {} // empty
}
