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

import "./ZSLMerkleTree.sol";

contract ZSLTestSuite {

    // TODO: Develop way to make it easy for user to track test results
    bool public testCommitmentsResult = false;
    // bool public testEmptyRootsResult = false;
    // bool public success = false; // if all tests passed

    // Source: zcash/src/test/data/merkle_commitments.json
    // Reverse byte order since the zcash gtest, test_merkletree.cpp uses uint256S()
    // to create the commitment from a hex string but reverses byte order intenally.
    bytes32[] public commitments =
    [
        bytes32(uint256(0x62fdad9bfbf17c38ea626a9c9b8af8a748e6b4367c8494caf0ca592999e8b6ba)),
        bytes32(uint256(0x68eb35bc5e1ddb80a761718e63a1ecf4d4977ae22cc19fa732b85515b2a4c943)),
        bytes32(uint256(0x836045484077cf6390184ea7cd48b460e2d0f22b2293b69633bb152314a692fb)),
        bytes32(uint256(0x92498a8295ea36d593eaee7cb8b55be3a3e37b8185d3807693184054cd574ae4)),
        bytes32(uint256(0xff7c360374a6508ae0904c782127ff5dce90918f3ee81cf92ef1b69afb8bf443)),
        bytes32(uint256(0x68c4d0f69d1f18b756c2ee875c14f1c6cd38682e715ded14bf7e3c1c5610e9fc)),
        bytes32(uint256(0x8b16cd3ec44875e4856e30344c0b4a68a6f929a68be5117b225b80926301e7b1)),
        bytes32(uint256(0x50c0b43061c39191c3ec529734328b7f9cafeb6fd162cc49a4495442d9499a2d)),
        bytes32(uint256(0x70ffdd5fa0f3aea18bd4700f1ac2e2e03cf5d4b7b857e8dd93b862a8319b9653)),
        bytes32(uint256(0xd81ef64a0063573d80cd32222d8d04debbe807345ad7af2e9edf0f44bdfaf817)),
        bytes32(uint256(0x8b92a4ec694271fe1b16cc0ea8a433bf19e78eb5ca733cc137f38e5ecb05789b)),
        bytes32(uint256(0x04e963ab731e4aaaaaf931c3c039ea8c9d7904163936e19a8929434da9adeba3)),
        bytes32(uint256(0xbe3f6c181f162824191ecf1f78cae3ffb0ddfda671bb93277ce6ebc9201a0912)),
        bytes32(uint256(0x1880967fc8226380a849c63532bba67990f7d0a10e9c90b848f58d634957c6e9)),
        bytes32(uint256(0xc465bb2893cba233351094f259396301c23d73a6cf6f92bc63428a43f0dd8f8e)),
        bytes32(uint256(0x84c834e7cb38d6f08d82f5cf4839b8920185174b11c7af771fd38dd02b206a20))
    ];

    // Source: zcash/src/test/data/merkle_roots.json
    bytes32[] public roots =
    [
            bytes32(uint256(0x95bf71d8e803b8601c14b5949d0f92690181154ef9d82eb3e24852266823317a)),
            bytes32(uint256(0x73f18d3f9cd11010aa01d4f444039e566f14ef282109df9649b2eb75e7a53ed1)),
            bytes32(uint256(0xdcde8a273c9672bee1a894d7f7f4abb81078f52b498e095f2a87d0aec5addf25)),
            bytes32(uint256(0x4677d481ec6d1e97969afbc530958d1cbb4f1c047af6fdad4687cd10830e02bd)),
            bytes32(uint256(0x74cd9d82de30c4222a06d420b75522ae1273729c1d8419446adf1184df61dc69)),
            bytes32(uint256(0x2ff57f5468c6afdad30ec0fb6c2cb67289f12584e2c20c4e0065f66748697d77)),
            bytes32(uint256(0x27e4ce010670801911c5765a003b15f75cde31d7378bd36540f593c8a44b3011)),
            bytes32(uint256(0x62231ef2ec8c4da461072871ab7bc9de10253fcb40e164ddbad05b47e0b7fb69)),
            bytes32(uint256(0x733a4ce688fdf07efb9e9f5a4b2dafff87cfe198fbe1dff71e028ef4cdee1f1b)),
            bytes32(uint256(0xdf39ed31924facdd69a93db07311d45fceac7a4987c091648044f37e6ecbb0d2)),
            bytes32(uint256(0x87795c069bdb55281c666b9cb872d13174334ce135c12823541e9536489a9107)),
            bytes32(uint256(0x438c80f532903b283230446514e400c329b29483db4fe9e279fdfc79e8f4347d)),
            bytes32(uint256(0x08afb2813eda17e94aba1ab28ec191d4af99283cd4f1c5a04c0c2bc221bc3119)),
            bytes32(uint256(0xa8b3ab3284f3288f7caa21bd2b69789a159ab4188b0908825b34723305c1228c)),
            bytes32(uint256(0xdb9b289e620de7dca2ae8fdac96808752e32e7a2c6d97ce0755dcebaa03123ab)),
            bytes32(uint256(0x0bf622cb9f901b7532433ea2e7c1b7632f5935899b62dcf897a71551997dc8cc))
    ];


    // Source: zcash/src/test/data/merkle_roots_empty.json
    bytes32[] public emptyRoots =
    [
        bytes32(uint(0x0000000000000000000000000000000000000000000000000000000000000000)),
        bytes32(uint(0xda5698be17b9b46962335799779fbeca8ce5d491c0d26243bafef9ea1837a9d8)),
        bytes32(uint(0xdc766fab492ccf3d1e49d4f374b5235fa56506aac2224d39f943fcd49202974c)),
        bytes32(uint(0x3f0a406181105968fdaee30679e3273c66b72bf9a7f5debbf3b5a0a26e359f92)),
        bytes32(uint(0x26b0052694fc42fdff93e6fb5a71d38c3dd7dc5b6ad710eb048c660233137fab)),
        bytes32(uint(0x0109ecc0722659ff83450b8f7b8846e67b2859f33c30d9b7acd5bf39cae54e31)),
        bytes32(uint(0x3f909b8ce3d7ffd8a5b30908f605a03b0db85169558ddc1da7bbbcc9b09fd325)),
        bytes32(uint(0x40460fa6bc692a06f47521a6725a547c028a6a240d8409f165e63cb54da2d23f)),
        bytes32(uint(0x8c085674249b43da1b9a31a0e820e81e75f342807b03b6b9e64983217bc2b38e)),
        bytes32(uint(0xa083450c1ba2a3a7be76fad9d13bc37be4bf83bd3e59fc375a36ba62dc620298)),
        bytes32(uint(0x1ddddabc2caa2de9eff9e18c8c5a39406d7936e889bc16cfabb144f5c0022682)),
        bytes32(uint(0xc22d8f0b5e4056e5f318ba22091cc07db5694fbeb5e87ef0d7e2c57ca352359e)),
        bytes32(uint(0x89a434ae1febd7687eceea21d07f20a2512449d08ce2eee55871cdb9d46c1233)),
        bytes32(uint(0x7333dbffbd11f09247a2b33a013ec4c4342029d851e22ba485d4461851370c15)),
        bytes32(uint(0x5dad844ab9466b70f745137195ca221b48f346abd145fb5efc23a8b4ba508022)),
        bytes32(uint(0x507e0dae81cbfbe457fd370ef1ca4201c2b6401083ddab440e4a038dc1e358c4)),
        bytes32(uint(0xbdcdb3293188c9807d808267018684cfece07ac35a42c00f2c79b4003825305d)),
        bytes32(uint(0xbab5800972a16c2c22530c66066d0a5867e987bed21a6d5a450b683cf1cfd709)),
        bytes32(uint(0x11aa0b4ad29b13b057a31619d6500d636cd735cdd07d811ea265ec4bcbbbd058)),
        bytes32(uint(0x5145b1b055c2df02b95675e3797b91de1b846d25003c0a803d08900728f2cd6a)),
        bytes32(uint(0x0323f2850bf3444f4b4c5c09a6057ec7169190f45acb9e46984ab3dfcec4f06a)),
        bytes32(uint(0x671546e26b1da1af754531e26d8a6a51073a57ddd72dc472efb43fcb257cffff)),
        bytes32(uint(0xbb23a9bba56de57cb284b0d2b01c642cf79c9a5563f0067a21292412145bd78a)),
        bytes32(uint(0xf30cc836b9f71b4e7ee3c72b1fd253268af9a27e9d7291a23d02821b21ddfd16)),
        bytes32(uint(0x58a2753dade103cecbcda50b5ebfce31e12d41d5841dcc95620f7b3d50a1b9a1)),
        bytes32(uint(0x925e6d474a5d8d3004f29da0dd78d30ae3824ce79dfe4934bb29ec3afaf3d521)),
        bytes32(uint(0x08f279618616bcdd4eadc9c7a9062691a59b43b07e2c1e237f17bd189cd6a8fe)),
        bytes32(uint(0xc92b32db42f42e2bf0a59df9055be5c669d3242df45357659b75ae2c27a76f50)),
        bytes32(uint(0xc0db2a74998c50eb7ba6534f6d410efc27c4bb88acb0222c7906ea28a327b511)),
        bytes32(uint(0xd7c612c817793191a1e68652121876d6b3bde40f4fa52bc314145ce6e5cdd259)),
        bytes32(uint(0xb22370106c67a17209f6130bc09f735d83aa2c04fc4fe72ea5d80b216723e7ce)),
        bytes32(uint(0x9f67d5f664664c901940eee3d02dd5b3e4b92e7b42820c42fc5159e91b41172a)),
        bytes32(uint(0xac58cd1388fec290d398f1944b564449a63c815880566bd1d189f7839e3b0c8c)),
        bytes32(uint(0x5698eae7c8515ed05a70339bdf7c1028e7acca13a4fa97d9538f01ac8d889ae3)),
        bytes32(uint(0x2d4995770a76fb93314ca74b3524ea1db5688ad0a76183ea17204a8f024a9f3b)),
        bytes32(uint(0x5e8992c1b072c16e9e28a85358fb5fb6901a81587766dadb7aa0b973ded2f264)),
        bytes32(uint(0xe95db71e1f7291ba5499461bc715203e29b84bfa4283e3bb7f470a15d0e1584e)),
        bytes32(uint(0x41f078bd1824c8a4b71964f394aa595084d8eb17b97a3630433af70d10e0eff6)),
        bytes32(uint(0xa1913fe6b20132312f8c1f00ddd63cec7a03f5f1d7d83492fa284c0b5d6320b0)),
        bytes32(uint(0xba9440c4dbfcf55ceb605a5b8990fc11f8ef22870d8d12e130f986491eae84b3)),
        bytes32(uint(0x49db2d5e22b8015cae4810d75e54014c5469862738e161ec96ec20218718828a)),
        bytes32(uint(0xd4851fb8431edfbb8b1e85ada6895967c2dac87df344992a05faf1ecf836eec9)),
        bytes32(uint(0xe4ab9f4470f00cd196d47c75c82e7adaf06fe17e042e3953d93bb5d56d8cd8fb)),
        bytes32(uint(0x7e4320434849ecb357f1afaaba21a54400ef2d11cff83b937d87fdafa49f8199)),
        bytes32(uint(0x020adc98d96cfbbcca15fc3aa03760ed286686c35b5d92c7cb64a999b394a854)),
        bytes32(uint(0x3a26b29fe1acfdd6c6a151bcc3dbcb95a10ebe2f0553f80779569b67b7244e77)),
        bytes32(uint(0xec2d0986e6a0ddf43897b2d4f23bb034f538ffe00827f310dc4963f3267f0bfb)),
        bytes32(uint(0xd48073f8819f81f0358e3fc35a047cc74082ae1cb7ee22fb609c01649342d0e6)),
        bytes32(uint(0xad8037601793f172441ecb00dc138d9fc5957125ecc382ec65e36f817dc799fb)),
        bytes32(uint(0xca500a5441f36f4df673d6b8ed075d36dae2c7e6481428c70a5a76b7a9bebce8)),
        bytes32(uint(0x422b6ddd473231dc4d56fe913444ccd56f7c61f747ba57ca946d5fef72d840a0)),
        bytes32(uint(0xab41f4ecb7d7089615800e19fcc53b8379ed05ee35c82567095583fd90ff3035)),
        bytes32(uint(0xbbf7618248354ceb1bc1fc9dbc42c426a4e2c1e0d443c5683a9256c62ecdc26f)),
        bytes32(uint(0xe50ae71479fc8ec569192a13072e011afc249f471af09500ea39f75d0af856bf)),
        bytes32(uint(0xe74c0b9220147db2d50a3b58d413775d16c984690be7d90f0bc43d99dba1b689)),
        bytes32(uint(0x29324a0a48d11657a51ba08b004879bfcfc66a1acb7ce36dfe478d2655484b48)),
        bytes32(uint(0x88952e3d0ac06cb16b665201122249659a22325e01c870f49e29da6b1757e082)),
        bytes32(uint(0xcdf879f2435b95af042a3bf7b850f7819246c805285803d67ffbf4f295bed004)),
        bytes32(uint(0xe005e324200b4f428c62bc3331e695c373607cd0faa9790341fa3ba1ed228bc5)),
        bytes32(uint(0x354447727aa9a53dd8345b6b6c693443e56ef4aeba13c410179fc8589e7733d5)),
        bytes32(uint(0xda52dda91f2829c15c0e58d29a95360b86ab30cf0cac8101832a29f38c3185f1)),
        bytes32(uint(0xc7da7814e228e1144411d78b536092fe920bcdfcc36cf19d1259047b267d58b5)),
        bytes32(uint(0xaba1f68b6c2b4db6cc06a7340e12313c4b4a4ea6deb17deb3e1e66cd8eacf32b)),
        bytes32(uint(0xc160ae4f64ab764d864a52ad5e33126c4b5ce105a47deedd75bc70199a5247ef)),
        bytes32(uint(0xeadf23fc99d514dd8ea204d223e98da988831f9b5d1940274ca520b7fb173d8a)),
        bytes32(uint(0x5b8e14facac8a7c7a3bfee8bae71f2f7793d3ad5fe3383f93ab6061f2a11bb02))
    ];


    // Assign address in constructor
    ZSLMerkleTree private tree;

    // @param a The address of the merkle tree we want to test
    function ZSLTestSuite(address a) {
        tree = ZSLMerkleTree(a);
    }

    function testEmptyRoots() public constant returns (bool) {
        // this test has enough empty roots for a tree of upto depth 65
        require(tree.depth() <= 65);

        for (uint i=0; i<tree.depth(); i++) {
            bytes32 rt = tree.getEmptyRoot(i);
            assert(rt == emptyRoots[i]);
        }
        return true;
    }

    /**
     @notice This test only runs against an empty merkle tree of depth 4
     @dev When calling from geth, to avoid error, specify gas e.g.
          contract.testCommitments({from:eth.coinbase, gas:4700000})
     @return void To find the result of the test, run:
          contract.testCommitmentsResult()
    */
    function testCommitments() public {
        // this test needs a tree of depth 4
        require(tree.depth() == 4);

        // only call this once, as we can't delete items from append only tree
        require(tree.size()==0);

        for (uint i=0; i<16; i++) {
            bytes32 cm = commitments[i];
            tree.addCommitment(cm);
            bytes32 rt =  tree.root(); // _calcSubtree(0, 4) ; // root if refactored
            assert(rt == roots[i]);
        }
        testCommitmentsResult = true;
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
