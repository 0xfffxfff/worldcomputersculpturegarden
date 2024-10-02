// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Sculpture.sol";

abstract contract PlaceholderSculpture is Sculpture {
    function title() external pure override virtual returns (string memory) {
        return "Untitled (Placeholder)";
    }

    function addresses() external view override virtual returns (address[] memory) {
        address[] memory addresses_ = new address[](1);
        addresses_[0] = address(0x0);
        return addresses_;
    }

    function text() public view override virtual returns (string memory) {}

    function urls() public view override virtual returns (string[] memory urls) {} // empty
}

contract Placeholder113 is PlaceholderSculpture {
    function authors() external view override returns (string[] memory) {
        string[] memory authors_ = new string[](1);
        authors_[0] = "113";
        return authors_;
    }
}

contract Placeholderpaulseidler is PlaceholderSculpture {

    function title() external pure override returns (string memory) {
        return "Real Abstraction (A Line Made by Proofs)";
    }

    function authors() external view override returns (string[] memory) {
        string[] memory authors_ = new string[](1);
        authors_[0] = "Paul Seidler";
        return authors_;
    }

    function addresses() external view override returns (address[] memory) {
        address[] memory addresses_ = new address[](2);
        addresses_[0] = address(0x6a7139325371a314Fe1374063869F89cB7c09D57);
        addresses_[1] = address(0x6Fc6FC7d76db89Dd30C19Df2B05b9fF339548EC8);
        return addresses_;
    }

    function text() public view override returns (string memory) {
        return
            "Two points on a map. The beginning of a virtual plane and the end, both connected by a straight line. Suddenly structures appear - drawn by entities with addresses. The line finds its way through the emerging labyrinth of walls, it adapts, through their curves and dead ends. At some point the whole structure solidifies, becomes immutable and invisible, unknowable. Only the line remains visible, while the actual origin from which the path was calculated is buried in a cryptographic proof, indecipherable to anyone who didn't take part in its creation. The physical materiality of the mathematical cryptographic proof constitutes an unknowable underlying structure. This plane is connected to another plane that starts from the same point of origin, which is connected to another, and so on - forming a possible infinite line whose underlying exact conditions of production can never be revealed. The appearance of the line is an artefact and remains a surface phenomenon of a cryptographic but provable underlying production.";
    }
}

contract Placeholder0xhaiku is PlaceholderSculpture {
    function authors() external view override returns (string[] memory) {
        string[] memory authors_ = new string[](1);
        authors_[0] = "0xhaiku";
        return authors_;
    }
}

contract Placeholderfigure31 is PlaceholderSculpture {
    function authors() external view override returns (string[] memory) {
        string[] memory authors_ = new string[](1);
        authors_[0] = "Loucas Braconnier (Figure31)";
        return authors_;
    }
}

contract Placeholderrheamyers is PlaceholderSculpture {
    function authors() external view override returns (string[] memory) {
        string[] memory authors_ = new string[](1);
        authors_[0] = "Rhea Myers";
        return authors_;
    }
}

contract Placeholdermaterial is PlaceholderSculpture {
    function authors() external view override returns (string[] memory) {
        string[] memory authors_ = new string[](1);
        authors_[0] = "Material";
        return authors_;
    }
}

contract Placeholdersarahfriend is PlaceholderSculpture {
    function authors() external view override returns (string[] memory) {
        string[] memory authors_ = new string[](1);
        authors_[0] = "Sarah Friend";
        return authors_;
    }
}
