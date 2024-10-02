// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "solady/src/utils/LibString.sol";
import "../Sculpture.sol";
import "../lib/Perlin.sol";

contract Travel is Sculpture {

    function title() public view override returns (string memory) {
       return "Dear God, Layer of Roads (Travellers)";
    }

    function authors() public view override returns (string[] memory) {
        string[] memory _authors = new string[](1);
        _authors[0] = "Loucas Braconnier (Figure31)";
        return _authors;
    }

    function addresses() public view override returns (address[] memory) {
        address[] memory _addresses = new address[](1);
        _addresses[0] = address(this);
        return _addresses;
    }

    function urls() public view override returns (string[] memory) {}

    function text() public view override returns (string memory) {
        Journey memory journey = journeys[1];
        uint256 count = block.number - uint(int(journey.fromBlock)) > 80 ? 80 : block.number - uint(int(journey.fromBlock));
        uint256 offset = block.number - uint(int(journey.fromBlock)) - count;
        return string.concat(
            unicode"This contract is a machine that lays time. It expands beyond the boundaries of the machine on which it operates. As time unravels, travellers may use it to journey toward both the future and the past. Once on this road, their presence simultaneously generates and marks the landscape. New land is discovered with every block of time, and with each passing day, fragments of these travellers are left behind for others to bear witness.",
            "<br/><br/>",
            unicode"DGLR (T) is a dynamic smart contract artwork on the Ethereum Blockchain, allowing individual addresses to travel through time, represented by Ethereum Blocks. These travellers may move forward or backward in time. As they freely start and end their journeys, each block spent travelling adds a character to an endlessly long string, shaping their individual landscape. With each passing day (approximately 7000 blocks), they leave a footprint on a collective landscape, which spreads and becomes part of all other individual landscapes. The contract’s limited read functions only allow viewers to generate fragments. However, complete landscapes can be generated off-chain using the algorithm provided within the contract.",
            "<br/><br/>",
            unicode"This artwork creates parallels between real and virtual time, scaling alongside another perpetually expanding network. It forever pushes beyond the limited computational environment of the Ethereum blockchain—a negative space growing within a positive one. After Michael Heizer, Double Negative.",
            "<br/><br/><br/>",
            landscape(1, offset, count)
        );
    }

    ////////////////////////////////////////////////////////////////////////////

    struct Journey {
        int48 fromBlock;
        int48 toBlock;
        bool forward;
        bool active;
        uint48 previousIndex; // index of the previous journey
        address traveller;
    }
    mapping(uint256 => Journey) public journeys;
    uint256 public journeyCount;
    uint256 public journeyCompletedCount;
    mapping(address => uint256) travellerCurrentJourney;

    constructor() {
        _begin(true, address(this));
    }

    function begin(bool direction) public {
        _begin(direction, msg.sender);
    }

    function _begin(bool direction, address traveller) internal {
        uint256 currentJourneyIndex = travellerCurrentJourney[traveller];
        Journey memory currentJourney = journeys[currentJourneyIndex];
        require(currentJourney.active == false, "You already have an active journey");
        journeyCount++;
        Journey memory newJourney = Journey({
            fromBlock: int48(int(block.number)),
            toBlock: 0,
            forward: direction,
            active: true,
            previousIndex: uint48(currentJourneyIndex),
            traveller: traveller
        });
        journeys[journeyCount] = newJourney;
        travellerCurrentJourney[traveller] = journeyCount;
    }

    function end() public {
        uint256 currentJourneyIndex = travellerCurrentJourney[msg.sender];
        Journey memory currentJourney = journeys[currentJourneyIndex];
        require(currentJourney.active == true, "You don't have an active journey");
        journeys[currentJourneyIndex].toBlock = int48(int(block.number));
        journeys[currentJourneyIndex].active = false;
        journeyCompletedCount++;
    }

    function howFarHaveICome() public view returns (int) {
        uint256 currentJourneyIndex = travellerCurrentJourney[msg.sender];
        Journey memory currentJourney = journeys[currentJourneyIndex];
        require(currentJourney.active == true, "You don't have an active journey");
        return int(block.number) - currentJourney.fromBlock;
    }

    function whereAmI() public view returns (int) {
        uint256 currentJourneyIndex = travellerCurrentJourney[msg.sender];
        Journey memory currentJourney = journeys[currentJourneyIndex];
        require(currentJourney.active == true, "You don't have an active journey");
        if (currentJourney.forward) {
            return int(block.number);
        } else {
            return currentJourney.fromBlock - int48(int(block.number) - currentJourney.fromBlock);
        }
    }

    function landscape(uint256 index, uint256 offset, uint256 limit) public view returns (string memory) {
        Journey memory journey = journeys[index];
        uint256 seed = uint256(uint160(journey.traveller)) + index; // later this might be prevrandao of end block
        require(index > 0 && index <= journeyCount, "Invalid journey index");

        string memory ls; // = LibString.toString(index);
        string[4] memory characters = ["_", "-", unicode"¯", unicode"ˇ"];

        int48 _fromBlock = journey.fromBlock;
        int48 _toBlock = journey.forward ? (journey.active ? int48(int(block.number)) : journey.toBlock) : journey.fromBlock - ((journey.active ? int48(int(block.number)) : journey.toBlock) - journey.fromBlock);

        uint256 counter = offset;

        while (true) {
            uint32 _x = journey.forward ? uint32(uint256(int(_fromBlock + int(counter))) % uint256(type(uint32).max)) : uint32(uint256(int(_fromBlock - int(counter))) % uint256(type(uint32).max));

            uint256 height = Perlin.computePerlin(_x, 0, uint32(seed), 64);
            // Estimated Practical range between 16 and 48 (0-64 is the theoretical range)
            // Put a ceiling on the height
            height = height > 43 ? 43 : height;
            // Lower the range by 16 (0-27)
            height = height > 16 ? height - 16 : 0;
            // Lower the range to raise the floor and create more flat lands
            // resulting in a final range of 0 to 16
            height = height > 11 ? height - 11 : 0;

            ls = string.concat(ls, characters[((height) * characters.length / 16) % characters.length]);

            counter++;

            if (
                (journey.forward && (uint256(int(_fromBlock)) + counter > uint256(int(_toBlock)) || counter > offset + limit))
                || (!journey.forward && (_fromBlock - int(counter) < _toBlock || counter > offset + limit))
            ) {
                break;
            }
        }

        return ls;
    }

}

