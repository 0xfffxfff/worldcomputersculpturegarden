// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solady/src/utils/LibString.sol";
import "../Sculpture.sol";


contract RemoteArtwork {
    function isArt() external view returns (bool) {
        return block.number % 2 == 0;
    }
}
interface IRemoteArtwork  {
    function isArt() external view returns (bool);
}

contract ExampleRemoteWork is Sculpture {

    address public immutable remoteArtwork;

    constructor(address _remoteArtwork) {
        remoteArtwork = _remoteArtwork;
    }

    function title() external view override returns (string memory) {
        return string.concat("Untitled");
    }

    function authors() external view override returns (string[] memory) {
        string[] memory authors_ = new string[](1);
        authors_[0] = "R.M.";
        return authors_;
    }

    function addresses() external view override returns (address[] memory) {
        address[] memory addresses_ = new address[](1);
        addresses_[0] = remoteArtwork;
        return addresses_;
    }

    function text() public view override returns (string memory) {
        return string.concat("Is Art: ", IRemoteArtwork(remoteArtwork).isArt() ? "Yes" : "No");
    }

    function urls() public view override returns (string[] memory urls) {} // empty
}