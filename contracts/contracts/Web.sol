// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "solady/src/auth/Ownable.sol";
import "solady/src/utils/LibString.sol";
import "./web/lib/Web3url.sol";
import "./Sculpture.sol";
import "./Essay.sol";
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

contract GardenRenderer is IWeb {

    address immutable public garden;
    address immutable public essayContract;
    address immutable public data;

    constructor(address _garden, address _essayContract, address _data) {
        garden = _garden;
        essayContract = _essayContract;
        data = _data;
    }

    function html() public view returns (string memory) {
        return index();
    }

    function index() public view returns (string memory html) {
        return GardenIndex.html(garden, essayContract, data);
    }

    function essay() public view returns (string memory html) {
        return GardenEssay.html(garden, essayContract);
    }

    function resolveMode() external pure returns (bytes32) {
        return "5219";
    }

    // ERC-5219
    function request(string[] memory resource, KeyValue[] memory params) external view returns (uint statusCode, string memory body, KeyValue[] memory headers) {
        // Index
        if(resource.length == 0) {
            body = index();
            statusCode = 200;
            headers = new KeyValue[](1);
            headers[0].key = "Content-Type";
            headers[0].value = "text/html; charset=utf-8";
            return (statusCode, body, headers);
        } else if (resource.length == 1 && keccak256(abi.encodePacked(resource[0])) == keccak256(abi.encodePacked("essay"))) {
            body = essay();
            statusCode = 200;
            headers = new KeyValue[](1);
            headers[0].key = "Content-Type";
            headers[0].value = "text/html; charset=utf-8";
            return (statusCode, body, headers);
        }

        statusCode = 404;
        return (statusCode, body, headers);
    }
}