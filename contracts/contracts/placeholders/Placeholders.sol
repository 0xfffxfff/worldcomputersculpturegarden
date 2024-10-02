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
    function title() public pure override returns (string memory) {
       return "Dear God, Layer of Roads (Travellers)";
    }

    function authors() public view override returns (string[] memory) {
        string[] memory _authors = new string[](1);
        _authors[0] = "Loucas Braconnier (Figure31)";
        return _authors;
    }

    function addresses() public view override returns (address[] memory) {
        address[] memory _addresses = new address[](1);
        _addresses[0] = address(0);
        return _addresses;
    }

    function urls() public view override returns (string[] memory) {}

    function text() public view override returns (string memory) {
        return string.concat(
            unicode"This contract is a machine that lays time. It expands beyond the boundaries of the machine on which it operates. As time unravels, travellers may use it to journey toward both the future and the past. Once on this road, their presence simultaneously generates and marks the landscape. New land is discovered with every block of time, and with each passing day, fragments of these travellers are left behind for others to bear witness.",
            "<br/><br/>",
            unicode"DGLR (T) is a dynamic smart contract artwork on the Ethereum Blockchain, allowing individual addresses to travel through time, represented by Ethereum Blocks. These travellers may move forward or backward in time. As they freely start and end their journeys, each block spent travelling adds a character to an endlessly long string, shaping their individual landscape. With each passing day (approximately 7000 blocks), they leave a footprint on a collective landscape, which spreads and becomes part of all other individual landscapes. The contract’s limited read functions only allow viewers to generate fragments. However, complete landscapes can be generated off-chain using the algorithm provided within the contract.",
            "<br/><br/>",
            unicode"This artwork creates parallels between real and virtual time, scaling alongside another perpetually expanding network. It forever pushes beyond the limited computational environment of the Ethereum blockchain—a negative space growing within a positive one. After Michael Heizer, Double Negative.",
            "<br/><br/>"
        );
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

    function text() public view override returns (string memory) {
        return "This is an example sculpture that is static.";
    }
}
