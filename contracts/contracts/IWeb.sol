// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "./web/lib/Web3url.sol";

interface IWeb is IDecentralizedApp {
    function html() external view returns (string memory);
}