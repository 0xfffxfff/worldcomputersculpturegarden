// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Format {
    function formatEther(uint256 weiAmount) internal pure returns (string memory) {
        uint256 etherAmountWhole = weiAmount / 1e18;
        uint256 etherAmountFraction = (weiAmount % 1e18) / 1e14;  // Get 4 decimals

        string memory fractionStr = removeTrailingZeroes(uint2str(etherAmountFraction));

        if (bytes(fractionStr).length > 0) {
            return string(abi.encodePacked(
                uint2str(etherAmountWhole),
                ".",
                fractionStr
            ));
        } else {
            return uint2str(etherAmountWhole);  // Return just the whole part if there are no decimals
        }
    }

    function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function removeTrailingZeroes(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        uint256 len = bStr.length;

        // Remove trailing zeros from the fractional part
        while (len > 0 && bStr[len - 1] == "0") {
            len--;
        }

        // Return the truncated string
        bytes memory trimmed = new bytes(len);
        for (uint256 i = 0; i < len; i++) {
            trimmed[i] = bStr[i];
        }

        return string(trimmed);
    }
}
