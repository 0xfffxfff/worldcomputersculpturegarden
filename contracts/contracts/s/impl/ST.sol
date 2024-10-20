// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "solady/src/auth/Ownable.sol";
import "../../lib/HitchensOrderStatisticsTreeLib.sol";
import "../S.sol";

contract ST is Ownable {
    address immutable public sp;

    using HitchensOrderStatisticsTreeLib for HitchensOrderStatisticsTreeLib.Tree;
    HitchensOrderStatisticsTreeLib.Tree tree;

    uint public totalContributions;
    mapping(address => uint) public contributions;

    constructor(address _sp, address _owner) {
        sp = _sp;
        _initializeOwner(_owner);
    }

    receive() external payable {
        if (msg.sender == sp) {
            return;
        }
        S(sp).sign(msg.sender, address(this));
        uint prevContribution = contributions[msg.sender];
        bytes32 key = bytes32(uint(uint160(msg.sender)));
        if (prevContribution > 0 && tree.keyExists(key, prevContribution)) {
            tree.remove(key, prevContribution);
        }
        tree.insert(key, prevContribution + msg.value);
        contributions[msg.sender] = prevContribution + msg.value;
        totalContributions += msg.value;
    }

    function topContributors(uint limit) public view returns (address[] memory contributors, uint[] memory contribs) {
        if (tree.count() == 0) {
            return (contributors, contribs);
        }
        uint top = tree.count() < limit ? tree.count() : limit;
        contributors = new address[](top);
        contribs = new uint[](top);
        uint count = 0;
        uint value = tree.atRank(tree.count()); // 1 is lowest rank, count() is highest rank
        while (value != 0 && count < top) {
            HitchensOrderStatisticsTreeLib.Node storage node = tree.getNode2(value);
            uint keyCount = node.keys.length;
            while (keyCount > 0) {
                keyCount--;
                address addr = address(uint160(uint(node.keys[keyCount])));
                contributors[count] = addr;
                contribs[count] = value;
                count++;
                if (count >= top) {
                    break;
                }
            }
            value = tree.prev(value);
        }
    }

    function withdraw(address _to) public onlyOwner() {
        (bool success, ) = _to.call{value: address(this).balance}("");
        require(success, "Failed to withdraw");
    }

    function treeFirstValue() public view returns (uint _value) {
        _value = tree.first();
    }
    function treeLastValue() public view returns (uint _value) {
        _value = tree.last();
    }
    function treeNextValue(uint value) public view returns (uint _value) {
        _value = tree.next(value);
    }
    function treePrevValue(uint value) public view returns (uint _value) {
        _value = tree.prev(value);
    }
    function treeValueExists(uint value) public view returns (bool _exists) {
        _exists = tree.exists(value);
    }
    function treeKeyValueExists(bytes32 key, uint value) public view returns(bool _exists) {
        _exists = tree.keyExists(key, value);
    }
    function treeGetNode(uint value) public view returns (uint _parent, uint _left, uint _right, bool _red, uint _keyCount, uint _count) {
        (_parent, _left, _right, _red, _keyCount, _count) = tree.getNode(value);
    }
    function treeGetValueKey(uint value, uint row) public view returns(bytes32 _key) {
        _key = tree.valueKeyAtIndex(value,row);
    }
    function treeValueKeyCount() public view returns(uint _count) {
        _count = tree.count();
    }
    function treeValuePercentile(uint value) public view returns(uint _percentile) {
        _percentile = tree.percentile(value);
    }
    function treeValuePermil(uint value) public view returns(uint _permil) {
        _permil = tree.permil(value);
    }
    function treeValueAtPercentile(uint _percentile) public view returns(uint _value) {
        _value = tree.atPercentile(_percentile);
    }
    function treeValueAtPermil(uint value) public view returns(uint _value) {
        _value = tree.atPermil(value);
    }
    function treeMedianValue() public view returns(uint _value) {
        return tree.median();
    }
    function treeValueRank(uint value) public view returns(uint _rank) {
        _rank = tree.rank(value);
    }
    function treeValuesBelow(uint value) public view returns(uint _below) {
        _below = tree.below(value);
    }
    function treeValuesAbove(uint value) public view returns(uint _above) {
        _above = tree.above(value);
    }
    function treeValueAtRank(uint _rank) public view returns(uint _value) {
        _value = tree.atRank(_rank);
    }
}