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

import "./ZTokenExample.sol";

// Bidder will own the contract when it is created, only the bidder can accept ask.

// Equity Trade
contract ZPrivateContract is owned {

    // Possible states of the private contract
    enum TradeState { Bid, Done, PaymentReceived, Settled, PaymentFailed, SettlementFailed }

    // State of the private contract
    TradeState public state;

    // ZToken contract for asset offered by bidder
    ZToken private bidToken;

    // Amount of bid asset
    uint64 public bidAmount;

    // Address of bidder 
    address public bidder;

    // ZToken contract for asset offered by asker
    ZToken private askToken;

    // Amount of ask asset
    uint64 public askAmount;

    // Address of asker
    address public asker;

    // Address of ZToken offered by asker
    address public askTokenAddress;

    // Address of ZToken offered by bidder
    address public bidTokenAddress;

    // Constellation address for bidd
    string public bidderConstellationAddress;

    // Constellation address for asker
    string public askerConstellationAddress;

    // Rho for the payment note received by bidder
    bytes32 public paymentReceivedByBidder;

    // Rho for the payment note received by asker
    bytes32 public paymentReceivedByAsker;

    // Shielded payment addresses
    bytes32 public bidderApk;
    bytes32 public askerApk;

    // Randomness
    bytes32 public randomness;
    bytes32 private bidderRandomness;
    bytes32 private askerRandomness;
    
    // Note: we can't log ztoken.name() as it results in error, inaccessible dynamic type
    event LogBidEvent(address indexed _from, uint _amount);
    event LogDoneEvent(address indexed _from);
    event LogPaymentEvent(address indexed _from);
    event LogSettlementEvent(address indexed _from);
    event LogPaymentFailedEvent(address indexed _from);
    event LogSettlementFailedEvent(address indexed _from);   



    function ZPrivateContract(
        bytes32 apk,
        bytes32 r,
        string bid_constellation,
        address bid_address,
        uint64 bid_amount,
        string ask_constellation,
        address ask_address,
        uint64 ask_amount)
    {
        bidderApk = apk;
        bidderRandomness = r;
        bidder = msg.sender;
        bidToken = ZToken(bid_address);
        bidTokenAddress = bid_address;
        bidAmount = bid_amount;
        bidderConstellationAddress = bid_constellation;
        askToken = ZToken(ask_address);
        askTokenAddress = ask_address;
        askAmount = ask_amount;
        askerConstellationAddress = ask_constellation;

        state = TradeState.Bid;
        LogBidEvent(msg.sender, bid_amount);
    }

    function toLittleEndian(uint64 value) internal constant returns (bytes) {
        bytes8 b = bytes8(value);
        bytes memory c = new bytes(8);
        for (uint i = 0; i < 8; i++) {
            c[i] = b[7-i];
        }
        return c;
    }


    function acceptBid(bytes32 apk, bytes32 r) public returns (bool result) {
        require(msg.sender != owner);
        require(state == TradeState.Bid);
        
        askerApk = apk;

        // randomness r = H(r_alice | r_bob)
        askerRandomness = r;
        randomness = sha256(bidderRandomness, askerRandomness);

        asker = msg.sender;
        state = TradeState.Done;
        LogDoneEvent(msg.sender);
        return true;    // for asker to see tx went through? prob. not necessary.
    }


    function submitPaymentDetails(bytes32 rho) onlyOwner public {
        require(state == TradeState.Done);

        // Calculate commitment from rho and verify it exists
        bytes32 cm = sha256(rho, askerApk, toLittleEndian(bidAmount));

        // FIXME Solidity 0.4.x: https://github.com/jpmorganchase/quorum/issues/82
        var exists = bidToken.commitmentExists(cm);

        if (exists) {
            paymentReceivedByAsker = rho;
            state = TradeState.PaymentReceived;
            LogPaymentEvent(msg.sender);
        } else {
            state = TradeState.PaymentFailed;
            LogPaymentFailedEvent(msg.sender);
        }
    }


    function submitSettlementDetails(bytes32 rho) public {
        require(msg.sender != owner);
        require(state == TradeState.PaymentReceived);

        // Verify for Bidder, Alice
        bytes32 cm = sha256(rho, bidderApk, toLittleEndian(askAmount));

        // FIXME Solidity 0.4.x: https://github.com/jpmorganchase/quorum/issues/82
        var exists = askToken.commitmentExists(cm);

        if (exists) {
            paymentReceivedByBidder = rho;
            state = TradeState.Settled;
            LogSettlementEvent(msg.sender);
        } else {
            state = TradeState.SettlementFailed;
            LogSettlementFailedEvent(msg.sender);
        }
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
