//pragma solidity ^0.4.10;

// Copyright 2017 Zerocoin Electric Coin Company LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import "./ZSLPrecompile.sol";

// @title ZSL Merkle Tree stores note commitments
contract ZSLMerkleTree {

    // ZSL contract
    ZSLPrecompile private zsl;

    uint private treeDepth;
    uint private maxNumElements;

    // Pre-computed empty roots
    bytes32[] private emptyRoots;

    // We store map index, i.e. index + 1, as 0 is used identify when a key is not found from the map.
    uint private numCommitments = 0;
    mapping (bytes32 => uint) private mapCommitmentIndices;
    mapping (uint => bytes32) private mapCommitments;

    // Constructor needs depth of tree
    function ZSLMerkleTree(uint depth) {
        zsl = ZSLPrecompile(new ZSLPrecompile());
        treeDepth = depth;
        maxNumElements = 2**depth;
        _createEmptyRoots(depth);
    }

    // Compute the empty tree roots
    function _createEmptyRoots(uint depth) private {
        bytes32 root = 0x00;
        emptyRoots.push(root);
        for (uint i=0; i<depth-1; i++) {
            root = combine(root, root);
            emptyRoots.push(root);
        }
    }

    // Return all the empty roots, one empty root for each depth
    function getEmptyRoots() public constant returns (bytes32[]) {
        return emptyRoots;
    }

    // Return the root for an empty tree of a given depth
    function getEmptyRoot(uint depth) public constant returns (bytes32) {
        require(depth < emptyRoots.length);
        return emptyRoots[depth];
    }

    /**
     * @notice SHA256Compress two leaves
     * @param left 32 bytes
     * @param right 32 bytes
     * @return result 256-bit hash
     */
    function combine(bytes32 left, bytes32 right) public constant returns (bytes32) {
        bytes memory buffer = new bytes(64);
        uint i;
        for (i=0; i<32; i++) {
            buffer[i] = left[i];
        }
        for (i=0; i<32; i++) {
            buffer[i + 32] = right[i];
        }
        return zsl.SHA256Compress(buffer);
    }
 
    /**
     * @notice Get the leaf index of a given commitment if it exists in the tree
     * @return i The leaf index
     */
    function getLeafIndex(bytes32 cm) public constant returns (uint) {
        uint mapIndex = mapCommitmentIndices[cm];
        require(mapIndex > 0);
        return mapIndex + 1;
    }

    /**
     * @notice Get commitment at a given leaf index
     * @param index Leaf index
     */
    function getCommitmentAtLeafIndex(uint index) public constant returns (bytes32) {
        require(index < numCommitments);
        uint mapIndex = index + 1;
        return mapCommitments[mapIndex];
    }

    /**
     * @notice Add commitment to the tree
     * @param cm Commitment
     */
    function addCommitment(bytes32 cm) public {
        // Only allow a commitment to be added once to the tree
        require(mapCommitmentIndices[cm] == 0);

        // Is tree full?
        require(numCommitments < maxNumElements);

        // Add new commitment
        uint mapIndex = ++numCommitments;

        mapCommitmentIndices[cm] = mapIndex;
        mapCommitments[mapIndex] = cm;
    }

    /**
     * @notice Has commitment already been added to the tree?
     * @param cm Commitment
     * @return bool True or false
     */
     function commitmentExists(bytes32 cm) public constant returns (bool) {
         return mapCommitmentIndices[cm] != 0;
     }

    /**
     * @return root Tree root representing the state of the tree
     */
    function root() public constant returns (bytes32) {
        return _calcSubtree(0, treeDepth);
    }

    /**
     * @return size Number of commitments stored in the tree
     */
    function size() public constant returns (uint) {
        return numCommitments;
    }

    /**
     * @return capacity Maxmimum number of commitments that can be stored in the tree
     */
    function capacity() public constant returns (uint) {
        return maxNumElements;
    }

    /**
     * @return available The number of commitments that can be appended to the tree
     */
    function available() public constant returns (uint) {
        return maxNumElements - numCommitments;
    }

    /**
     * @return depth The fixed tree depth
     */
    function depth() public constant returns (uint) {
        return treeDepth;
    }

    /**
     * Recursively calculate the root for a given position in the tree.
     * @param index Leaf index of item
     * @param item_depth depth Depth of item
     * @return root Tree root of the given item
     */
    function _calcSubtree(uint index, uint item_depth) private constant returns (bytes32) {
        // Use pre-computed empty tree root if we know other half of tree is empty
        if (numCommitments <= leftShift(index, item_depth)) {
            return emptyRoots[item_depth];
        }   

        if (item_depth == 0) {
            uint mapIndex = index + 1;
            return mapCommitments[mapIndex];
        } else {
            bytes32 left = _calcSubtree( leftShift(index, 1), item_depth - 1);
            bytes32 right = _calcSubtree( leftShift(index, 1) + 1, item_depth - 1);
            return combine(left, right);
        }
    }

    /**
     * @notice Get witness information related for a given commitment
     * @param cm Commitment
     * @return index The leaf index of the commitment
     * @return array List of uncles for the commitment
     */
    function getWitness(bytes32 cm) public constant returns (uint, bytes32[]) {
        uint mapIndex = mapCommitmentIndices[cm];
        require(mapIndex > 0);
        uint index = mapIndex - 1;
        bytes32[] memory uncles = new bytes32[](treeDepth);
        uint cur_depth = 0;
        uint cur_index = index;
        uint i = 0;
        while (cur_depth < treeDepth) {
            uncles[i++] = _calcSubtree( cur_index ^ 1, cur_depth++);
            cur_index = rightShift(cur_index, 1);
        }
        return (index, uncles);
    }

    // Fallback function for unknown function signature to prevent accidental sending of ether
    function () {
        revert();
    }


    /*
      Utility functions when compiling with solidity 0.3.6
    */
    function assert(bool assertion) internal {
      if (!assertion) {
        throw;
      }
    }

    function require(bool requirement) internal {
      if (!requirement) {
        throw;
      }
    }

    function revert() internal {
      throw;
    }

    function leftShift(uint256 v, uint256 n) returns (uint256) {
        return v * (2 ** n);
    }

    function rightShift(uint256 v, uint256 n) returns (uint256) {
        return v / (2 ** n);
    }

}
