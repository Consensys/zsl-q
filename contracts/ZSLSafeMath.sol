// pragma solidity ^0.4.10;

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

/*
    Catch underflow and overflow errors
*/
contract SafeMath {

    // z = x + y
    function safeAdd(uint256 x, uint256 y) internal returns (uint256) {
      uint256 z = x + y;
      assert((z >= x) && (z >= y));
      return z;
    }

    // x is expected to be greater than or equal to y, e.g. z = x - y
    function safeSubtract(uint256 x, uint256 y) internal returns (uint256) {
      assert(x >= y);
      uint256 z = x - y;
      return z;
    }

    // z = x * y
    function safeMultiply(uint256 x, uint256 y) internal returns (uint256) {
      uint256 z = x * y;
      assert((x == 0)||(z/x == y));
      return z;
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
