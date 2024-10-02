// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "solady/src/utils/LibString.sol";
import "../Sculpture.sol";
import "../lib/Perlin.sol";

contract Travel is Sculpture {
    // Overview
    // - Entry and Exit of Addresses (OK)
    // - Travelers can do multiple journeys (Multiple logs) (OK)
    // - Travel backwards or forwards (from current block) (OK)
    // - Characters for terrain (VERIFY)
    // - Footprints at intervals (TODO)
    // - Selection of characters for footprints (TODO)
    // - Journey only renderable after we have the full journey (after exit) (TODO)
    // - Footprint should always be on the same block (TODO)
    // - the contract itself also travels in both directions and has a footprint (ONLY FORWARD)
    // - When we reach block 1 when travelling backwards then we go negative (VERIFY)
    // - Markers at regular intervals

    constructor() {
        _begin(true, address(this));
    }

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
    mapping(uint256 => uint256) travellerFootprint;

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

    uint256 constant PRECISION = 10;
    uint256 constant SCALE = 10 ** PRECISION; // Scaling factor to map values between 0 and 10,000

    // Function to get height with noise thresholding
    function getHeight(uint256 seed, uint256 x) public pure returns (uint256) {
        uint256 noise = valueNoise(seed, x * SCALE / 10); // Adjust position scaling if necessary
        return noise > 1_400 ? noise - 1_400 : 0;
    }


    // Seedable 1D value noise function
    function valueNoise(uint256 seed, uint256 position) public pure returns (uint256) {
        // Find the two surrounding lattice points
        uint256 left = position / SCALE; // Integer lattice point
        uint256 right = left + 1;        // Next lattice point

        // Hash to get pseudo-random values at lattice points
        uint256 leftValue = uint256(keccak256(abi.encodePacked(seed, left))) % SCALE;
        uint256 rightValue = uint256(keccak256(abi.encodePacked(seed, right))) % SCALE;

        // Compute the relative position 't' between left and right points
        uint256 t = position % SCALE;

        // Perform linear interpolation between the two points
        return lerp(leftValue, rightValue, t);
    }

    // Linear interpolation function
    function lerp(uint256 a, uint256 b, uint256 t) internal pure returns (uint256) {
        // t is expected to be a value between 0 and 1 scaled by SCALE (i.e., t = t * 10_000)
        uint256 diff = (a > b ? a - b : b - a) * t / SCALE;
        return a > b ? a - diff : a + diff;
    }

    function landscape(uint256 index, uint256 offset, uint256 limit) public view returns (string memory) {
        Journey memory journey = journeys[index];
        uint256 seed = uint256(uint160(journey.traveller)) + index; // later this might be prevrandao of end block
        require(index > 0 && index <= journeyCount, "Invalid journey index");
        require(index == 1 || journey.active == false, "Journey is not yet complete");
        // TODO: Validate offset and limit

        int48 length = journey.toBlock - journey.fromBlock;
        uint256 counter = offset;
        string memory ls;

        string[4] memory characters = ["_", "-", unicode"¯", unicode"ˇ"];

        int48 _fromBlock = journey.fromBlock;
        int48 _toBlock = journey.forward ? (journey.active ? int48(int(block.number)) : journey.toBlock) : journey.fromBlock - ((journey.active ? int48(int(block.number)) : journey.toBlock) - journey.fromBlock);

        if (journey.forward) {
            while (true) {
                uint32 _x = uint32(uint256(int(_fromBlock + int(counter))) % uint256(type(uint32).max));
                // int256 _y = int(uint256(keccak256(abi.encodePacked(msg.sender)))) % 1_000_000;
                uint256 height = Perlin.computePerlin(_x, 3, uint32(seed), 64);
                // we estimate the range is between 16 and 48
                height = height - 16;
                // we put a ceiling on the height
                height = height > 27 ? 27 : height;
                // we lower the range to raise the floor and create more flat lands
                height = height > 11 ? height - 11 : 0;
                // which gives us a final range of 0 to 16
                ls = string.concat(ls, characters[((height) * characters.length / 16) % characters.length]);
                counter++;
                if (uint256(int(_fromBlock)) + counter > uint256(int(_toBlock)) || counter >= offset + limit) {
                    break;
                }
            }
        } else {
            while (true) {
                uint32 _x = uint32(uint256(int(_fromBlock - int(counter))) % uint256(type(uint32).max));
                // int256 _y = int(uint256(keccak256(abi.encodePacked(msg.sender)))) % 1_000_000;
                uint256 height = Perlin.computePerlin(_x, 3, uint32(seed), 64);
                // we estimate the range is between 16 and 48
                height = height - 16;
                // we put a ceiling on the height
                height = height > 28 ? 28 : height;
                // we lower the range to raise the floor and create more flat lands
                height = height > 11 ? height - 11 : 0;
                // which gives us a final range of 0 to 16
                ls = string.concat(ls, characters[((height) * characters.length / 16) % characters.length]);
                counter++;
                if (_fromBlock - int(counter) < _toBlock || counter >= offset + limit) {
                    break;
                }
            }
        }

        return ls;
    }

    function title() public view override returns (string memory) {
        // return string.concat("There ",
        //     journeyCount - journeyCompletedCount == 1 ? "is " : "are ",
        //     journeyCount - journeyCompletedCount == 0 ? "no " : LibString.toString(journeyCount - journeyCompletedCount),
        //     " traveler",
        //     journeyCount - journeyCompletedCount == 1 ? "" : "s",
        //     " on the road.");
        return string.concat("There Are Travellers on the Road");
    }

    function authors() public view override returns (string[] memory) {
        string[] memory _authors = new string[](1);
        _authors[0] = "Loucas Braconnier (Figure 31)";
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
        uint256 chars = 64;
        uint256 count = block.number - uint(int(journey.fromBlock)) > chars ? chars : block.number - uint(int(journey.fromBlock));
        uint256 offset = block.number - uint(int(journey.fromBlock)) - count;
        return string.concat(
            landscape(1, offset, count)
        );
    }
}

