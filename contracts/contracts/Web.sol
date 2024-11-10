// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "solady/src/auth/Ownable.sol";
import "solady/src/utils/LibString.sol";
import "./web/lib/Web3url.sol";
import "./Sculpture.sol";
import "./Essay.sol";
import "./web/GardenRenderer.sol";
import "./web/GardenIndex.sol";
import "./web/GardenEssay.sol";

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

    function resolveMode() external view returns (bytes32) {
        return GardenRenderer(renderer).resolveMode();
    }
}