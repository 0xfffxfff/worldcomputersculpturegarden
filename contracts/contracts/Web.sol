// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solady/src/auth/Ownable.sol";
import "./IWeb.sol";

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
        return IWeb(renderer).html();
    }

    function request(string[] memory resource, KeyValue[] memory params) external view returns (uint statusCode, string memory body, KeyValue[] memory headers) {
        return IWeb(renderer).request(resource, params);
    }

    function resolveMode() external view returns (bytes32) {
        return IWeb(renderer).resolveMode();
    }
}