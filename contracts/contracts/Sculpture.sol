// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

interface Sculpture {

    function title() external view returns (string memory);

    function authors() external view returns (string[] memory);

    function addresses() external view returns (address[] memory);

    function links() external view returns (string[] memory);

    function text() external view returns (string memory);

    // function representation(string memory mimetype) external view returns (string memory);

    // function canconicalRepresentation() external view returns (string memory);

    // How should this be presented/displayed/shown/represented?
    // function representation() external view returns (string memory);

}
