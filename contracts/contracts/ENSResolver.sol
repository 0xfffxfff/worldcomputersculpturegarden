// SPDX-License-Identifier: UNLICENSED
// Author: @yigitduman
// Source: https://github.com/ygtdmn/drakeflipping/blob/main/src/DrakeflippingRenderer.sol
pragma solidity >=0.8.0;

import "solady/src/utils/LibString.sol";
import { ENS } from "@ensdomains/ens-contracts/contracts/registry/ENS.sol";
import { IReverseRegistrar } from "@ensdomains/ens-contracts/contracts/reverseRegistrar/IReverseRegistrar.sol";
import { INameResolver } from "@ensdomains/ens-contracts/contracts/resolvers/profiles/INameResolver.sol";

library ENSResolver {
    /**
     * @notice Retrieves the ENS name or checksummed address for a given address.
     * @param addr The address to retrieve the ENS name or checksummed address for.
     * @return The ENS name if available, otherwise the checksummed address.
     */
    function resolveAddress(address addr) external view returns (string memory) {
        ENS ens = ENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);
        IReverseRegistrar reverseRegistrar = IReverseRegistrar(/*sepolia*/0xA0a1AbcDAe1a2a4A2EF8e9113Ff0e02DD81DC0C6);
        bytes32 node = reverseRegistrar.node(addr);
        address resolverAddress = ens.resolver(node);

        if (resolverAddress != address(0)) {
            // If the resolver is not the zero address, try to get the name from the resolver
            try INameResolver(resolverAddress).name(node) returns (string memory name) {
                // If a name is found and it's not empty, return it
                if (bytes(name).length > 0) {
                    return name;
                }
            } catch {}
        }

        // If no valid name is found, return the address as a string
        return LibString.toHexStringChecksummed(addr);
    }
}