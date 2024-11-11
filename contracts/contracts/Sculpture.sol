// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

////////////////////////////////////////////////////////////////////////
//                                                                    //
//                                                                    //
//                                                                    //
//                                                                    //
//                                                                    //
//                                                                    //
//                                                                    //
//                                                                    //
//                                 ⚘                                  //
//                             sculpture                              //
//                                                                    //
//                                                                    //
//                                                                    //
//                                                                    //
//                                                                    //
//                                                                    //
//                                                                    //
//                                                                    //
////////////////////////////////////////////////////////////////////////

interface Sculpture {

    function title() external view returns (string memory);

    function authors() external view returns (string[] memory);

    function addresses() external view returns (address[] memory);

    function urls() external view returns (string[] memory);

    function text() external view returns (string memory);

}
