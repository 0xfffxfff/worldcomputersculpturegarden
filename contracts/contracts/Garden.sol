// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

////////////////////////////////////////////////////////////////////////
//                                                                    //
//     ⚘                    ⚘                              ⚘          //
//                                        ⚘                           //
//            ⚘                                                       //
//                                 ⚘                            ⚘     //
//                                                 ⚘                  //
//         ⚘                                                          //
//                 the world computer                                 //
//                                                           ⚘        //
//                           is a sculpture garden                    //
//          ⚘                                                         //
//                                               ⚘               ⚘    //
//                           ⚘                                        //
//       ⚘                                 ⚘            ⚘             //
//                   ⚘                                                //
//                                ⚘                                   //
//                                                                    //
////////////////////////////////////////////////////////////////////////

import "solady/src/auth/Ownable.sol";
import "solady/src/utils/SSTORE2.sol";
import "./Sculpture.sol";
import "./Web.sol";
import "./FlowerGuestbook.sol";
import "./Mod.sol";

contract Garden is Sculpture, FlowerGuestbook {

    address[] public sculptures;

    address public immutable data;

    address public immutable render;

    ///////////////////////////////////////////////////////////////////////////
    // Init
    ///////////////////////////////////////////////////////////////////////////

    constructor(address[] memory _sculptures, address _render, address _data) {
        sculptures = _sculptures;
        render = _render;
        data = _data;
    }

    ///////////////////////////////////////////////////////////////////////////
    // Web
    ///////////////////////////////////////////////////////////////////////////

    function html() external view returns (string memory) {
        return IWeb(render).html();
    }

    function resolveMode() external view returns (bytes32) {
        return IWeb(render).resolveMode();
    }

    function request(string[] memory resource, KeyValue[] memory params) external view returns (uint statusCode, string memory body, KeyValue[] memory headers) {
        return IWeb(render).request(resource, params);
    }

    fallback() external payable {
        revert(LibString.toHexString(abi.encodeWithSignature("html()")));
    }

    ///////////////////////////////////////////////////////////////////////////
    // Sculptures
    ///////////////////////////////////////////////////////////////////////////

    function getSculptures() public view returns (address[] memory) {
        return sculptures;
    }

    function setSculptures(address[] memory _sculptures) public onlyOwner {
        sculptures = _sculptures;
    }

    ///////////////////////////////////////////////////////////////////////////
    // Show
    ///////////////////////////////////////////////////////////////////////////

    function title() external pure returns (string memory) {
        return "World Computer Sculpture Garden";
    }

    function authors() external view returns (string[] memory) {
        uint256 length = 1; // fff
        for (uint256 i = 0; i < sculptures.length; i++) {
            string[] memory sculptureAuthors = Sculpture(sculptures[i]).authors();
            for (uint256 j = 0; j < sculptureAuthors.length; j++) {
                length++;
            }
        }
        string[] memory authors_ = new string[](length);
        uint256 index;
        for (uint256 i = 0; i < sculptures.length; i++) {
            string[] memory sculptureAuthors = Sculpture(sculptures[i]).authors();
            for (uint256 j = 0; j < sculptureAuthors.length; j++) {
                authors_[index] = sculptureAuthors[j];
                index++;
            }
        }
        authors_[index] = Mod(data).fff();
        return authors_;
    }

    function addresses() external view returns (address[] memory) {
        uint256 length = 1; // Garden itself
        for (uint256 i = 0; i < sculptures.length; i++) {
            address[] memory sculptureAddresses = Sculpture(sculptures[i]).addresses();
            for (uint256 j = 0; j < sculptureAddresses.length; j++) {
                length++;
            }
        }
        address[] memory addresses_ = new address[](length);
        uint256 index = 1; // Garden itself
        addresses_[0] = address(this);
        for (uint256 i = 0; i < sculptures.length; i++) {
            Sculpture sculpture = Sculpture(sculptures[i]);
            address[] memory sculptureAddresses = sculpture.addresses();
            for (uint256 j = 0; j < sculptureAddresses.length; j++) {
                addresses_[index] = sculpture.addresses()[j];
                index++;
            }
        }
        return addresses_;
    }

    function text() public view returns (string memory) {
        return Mod(data).text();
    }

    function urls() public view returns (string[] memory) {
        return Mod(data).urls();
    }
}