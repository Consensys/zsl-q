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

/**
 @title Abstract contract for built-in function
 */
contract ZSLPrecompileSHA256Compress {
    function run(bytes) constant returns (bytes32);
}

/**
 @title Abstract contract for built-in function
 */
contract ZSLPrecompileVerifyShielding {
    function run(bytes, bytes32, bytes32, uint64) constant returns (bytes32);
}

/**
 @title Abstract contract for built-in function
 */
contract ZSLPrecompileVerifyUnshielding {
    function run(bytes, bytes32, bytes32, address, uint64) constant returns (bytes32);
}

/**
 @title Abstract contract for built-in function
 */
contract ZSLPrecompileVerifyTransfer {
    function run(bytes, bytes32, bytes32, bytes32, bytes32, bytes32, bytes32, bytes32) constant returns (bytes32);
}

/**
 @title ZSL contract
 */
contract ZSLPrecompile {

    ZSLPrecompileSHA256Compress private compressContract;
    ZSLPrecompileVerifyTransfer private verifyShieldedTransferContract;
    ZSLPrecompileVerifyShielding private verifyShieldingContract;
    ZSLPrecompileVerifyUnshielding private verifyUnshieldingContract;

    // @dev Address of precompiles must match those in the Geth/Quorum client
    function ZSLPrecompile() {
        compressContract = ZSLPrecompileSHA256Compress(0x0000000000000000000000000000000000008801);
        verifyShieldedTransferContract = ZSLPrecompileVerifyTransfer(0x0000000000000000000000000000000000008802);
        verifyShieldingContract = ZSLPrecompileVerifyShielding(0x0000000000000000000000000000000000008803);
        verifyUnshieldingContract = ZSLPrecompileVerifyUnshielding(0x0000000000000000000000000000000000008804);
    }

    // @param input Input data block must be 64 bytes (512 bits) in length
    function SHA256Compress(bytes input) constant external returns (bytes32 result) {
        require(input.length == 64);
        return compressContract.run(input);
    }

    // @param input The ZK Proof to verify
    function verifyShieldedTransfer(
        bytes proof,
        bytes32 anchor,
        bytes32 spend_nf_1,
        bytes32 spend_nf_2,
        bytes32 send_nf_1,
        bytes32 send_nf_2,
        bytes32 cm_1,
        bytes32 cm_2
    ) constant external returns (bool) {
        bytes32 buffer = verifyShieldedTransferContract.run(
            proof, anchor, spend_nf_1, spend_nf_2,
            send_nf_1, send_nf_2, cm_1, cm_2);
        byte b = buffer[0];
        if (b == 0x00) {
            return false;
        } else if (b == 0x01) {
            return true;
        }
        assert(false);
    }


    // @param input The ZK Proof to verify
    function verifyShielding(bytes proof, bytes32 send_nf, bytes32 cm, uint64 value) constant external returns (bool) {
        bytes32 buffer = verifyShieldingContract.run(proof, send_nf, cm, value);
        byte b = buffer[0];
        if (b == 0x00) {
            return false;
        } else if (b == 0x01) {
            return true;
        }
        assert(false);
    }



    // @param input The ZK Proof to verify
    function verifyUnshielding(bytes proof, bytes32 spend_nf, bytes32 rt, address addr, uint64 value) constant external returns (bool) {
        bytes32 buffer = verifyUnshieldingContract.run(proof, spend_nf, rt, addr, value);
        byte b = buffer[0];
        if (b == 0x00) {
            return false;
        } else if (b == 0x01) {
            return true;
        }
        assert(false);
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

}
