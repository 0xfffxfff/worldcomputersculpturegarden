// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./Sculpture.sol";
import "./Web.sol";

contract Garden is Sculpture {

    address[] public sculptures;
    address public render;

    constructor(address[] memory _sculptures, address _render) {
        sculptures = _sculptures;
        render = _render;
    }

    receive() external payable {
        sign();
    }

    fallback() external payable {
        revert(IWeb(render).html());
    }

    function html() external view returns (string memory) {
        return IWeb(render).html();
    }

    function getSculptures() public view returns (address[] memory) {
        return sculptures;
    }

    ///////////////////////////////////////////////////////////////////////////
    // Show
    ///////////////////////////////////////////////////////////////////////////

    function title() external pure returns (string memory) {
        return "World Computer Sculpture Garden";
    }

    function authors() external view returns (string[] memory) {
        string[] memory authors_;
        for (uint256 i = 0; i < sculptures.length; i++) {
            string[] memory sculptureAuthors = Sculpture(sculptures[i]).authors();
            for (uint256 j = 0; j < sculptureAuthors.length; j++) {
                authors_[authors_.length] = sculptureAuthors[j];
            }
        }
        return authors_;
    }

    function addresses() external view returns (address[] memory) {
        address[] memory addresses_;
        for (uint256 i = 0; i < sculptures.length; i++) {
            Sculpture sculpture = Sculpture(sculptures[i]);
            address[] memory sculptureAddresses = sculpture.addresses();
            for (uint256 j = 0; j < sculptureAddresses.length; j++) {
                addresses_[addresses_.length] = sculpture.addresses()[j];
            }
        }
        return addresses_;
    }

    function text() public view returns (string memory) {
        return "here be exhibition text";
    }

    function urls() public view returns (string[] memory) {
        string[] memory urls_;
        // Here be a link
        return urls_;
    }


    ///////////////////////////////////////////////////////////////////////////
    // Public Garden Contributions
    // TODO: Credit 113
    ///////////////////////////////////////////////////////////////////////////

    event ContributionMade(address indexed contributor, uint256 amount);

    uint256 public contributed;
    mapping(uint256 => uint256) public contributions;

    /// @notice Contribute and plant a tree in the garden
    function sign() public payable {
        require(msg.value >= 0.01 ether, "Contribute at least 0.01");
        contributed += 1;
        uint256 amount = msg.value / 0.01 ether;
        contributions[contributed] = uint256(
            (amount << 160) | uint160(msg.sender)
        );
        emit ContributionMade(msg.sender, msg.value);
    }

    function getContribution(uint256 index) public view returns (address contributor, uint256 amount) {
        uint256 contribution = contributions[index];
        contributor = address(uint160(contribution));
        amount = contribution >> 160;
    }

    function getContributed() public view returns (uint256) {
        return contributed;
    }
}