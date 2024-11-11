// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Format {
    function stripURL(string memory url) internal pure returns (string memory) {
        bytes memory urlBytes = bytes(url);
        uint256 length = urlBytes.length;
        uint256 start = 0;
        uint256 end = length;

        // Handle "data:" URLs first
        if (length >= 5 && urlBytes[0] == "d" && urlBytes[1] == "a" && urlBytes[2] == "t" && urlBytes[3] == "a" && urlBytes[4] == ":") {
            // we want a shortened version of the data URL, that replaces everything after the first comma with "..."
            // e.g. "data:text/plain;base64,..."
            for (uint256 i = 5; i < length; i++) {
                if (urlBytes[i] == ",") {
                    end = i;
                    break;
                }
            }
        // Otherwise, handle other URLs
        } else {

            // Find the position of "://", which indicates the end of the protocol
            for (uint256 i = 0; i < length - 2; i++) {
                if (urlBytes[i] == ":" && urlBytes[i + 1] == "/" && urlBytes[i + 2] == "/") {
                    start = i + 3; // Skip the "://"max
                    break;
                }
            }

            // Find position of "?" or "#" to determine the end of the main URL
            for (uint256 i = start; i < length; i++) {
                if (urlBytes[i] == "?" || urlBytes[i] == "#") {
                    end = i;
                    break;
                }
            }

            // Remove trailing slash if present
            if (end > start && urlBytes[end - 1] == "/") {
                end -= 1;
            }
        }

        // Create a new byte array to store the stripped URL
        bytes memory strippedUrlBytes = new bytes(end - start);
        for (uint256 i = start; i < end; i++) {
            strippedUrlBytes[i - start] = urlBytes[i];
        }

        return string(strippedUrlBytes);
    }

    function renderUrl(string memory url) internal pure returns (string memory) {
        string memory strippedUrl = stripURL(url);
        return string.concat('<a href="', url, '" target="_blank" rel="noopener noreferrer">', strippedUrl ,'</a>');
    }

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

    function stringToUint(string memory s) internal pure returns (uint result) {
        bytes memory b = bytes(s);
        result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            uint256 c = uint256(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
        return result;
    }
}

