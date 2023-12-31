// // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2 } from "forge-std/Test.sol";
import { ProofPool, TaskAssignment, TaskStatus } from "../src/ProofPool.sol";
import { RewardERC20, BondERC20 } from "./SomeERC20.sol";
import { YulDeployer } from "./YulDeployer.sol";
import { LibBytesUtils } from "../src/libs/LibBytesUtils.sol";
import { Token } from "../src/Token.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

interface SomeVerifier {}


contract ProofPoolTest is Test {

    using ECDSA for bytes32;

    
    uint256 private _seed = 0x12345678;

    function getRandomAddress() internal returns (address, uint256) {
        uint256 privateKey = uint256(keccak256(abi.encodePacked("address", _seed++)));
        return (vm.addr(privateKey), privateKey);
    }


    uint256 internal ownerPrivateKey;
    address internal owner;
    uint256 internal requesterPrivateKey;
    address internal requester;
    uint256 internal proverPrivateKey;
    address internal prover;
    uint256 internal openProverPrivateKey;
    address internal openProver;

    RewardERC20 rewardToken;
    BondERC20 bondToken;

    ProofPool public proofPool;

    YulDeployer yulDeployer = new YulDeployer();
    SomeVerifier someVerifer;

    Token arkToken;

    
    function setUp() public {
        
        proverPrivateKey = 0xdb96b69680aee75d9b9b952b9cfb11bebef7c9f36a66147675d0219aa69306df;
        prover = vm.addr(proverPrivateKey);

        (owner, ownerPrivateKey) = getRandomAddress();
        (requester, requesterPrivateKey) = getRandomAddress();
        // (prover, proverPrivateKey) = getRandomAddress();
        (openProver, openProverPrivateKey) = getRandomAddress();

        rewardToken = new RewardERC20(100 ether);
        bondToken = new BondERC20(100 ether);
        rewardToken.transfer(requester, 50 ether);
        bondToken.transfer(prover, 50 ether);

        // someVerifer = SomeVerifier(yulDeployer.deployContract("SomeVerifier"));
        // console2.log("someVerifer's address:", address(someVerifer));

        proofPool = new ProofPool(
            owner,
            address(bondToken),
            10 ether,
            address(0), // mock verifier
            3600,
            32
        );

        arkToken = new Token();

    }

    // function test_arkToken() public {

    //     arkToken.mint(owner, 10 ether);
    //     arkToken.mint(requester, 10 ether);

    //     console2.log("The balance of owner:", arkToken.balance(owner));
    //     console2.log("The balance of requester:", arkToken.balance(requester));

    //     vm.startPrank(owner);
    //     arkToken.transfer(requester, 1 ether);
    //     console2.log("The balance of owner:", arkToken.balance(owner));
    //     console2.log("The balance of requester:", arkToken.balance(requester));

    // }

    // function test_updateConfig() public {

    //     vm.startPrank(owner);
    //     proofPool.updateConfig(
    //         address(bondToken),
    //         10 ether,
    //         address(someVerifer),
    //         3600,
    //         64
    //     );

    // }

    // function test_submitTask() public {

    //     bytes memory instance = hex"AB";

    //     // Start the signature
    //     vm.startPrank(prover);
    //     bytes32 digest = keccak256(
    //         abi.encode(
    //             instance,
    //             address(rewardToken),
    //             5 ether,
    //             block.timestamp + 3600
    //         )
    //     );
    //     (uint8 v, bytes32 r, bytes32 s) = vm.sign(proverPrivateKey, digest);
    //     bytes memory signature = abi.encodePacked(r, s, v);
    //     vm.stopPrank();

    //     // ERC20 approval by requester
    //     vm.startPrank(requester);
    //     rewardToken.approve(address(proofPool), type(uint256).max);
    //     vm.stopPrank();
    //     // ERC20 approval by Prover
    //     vm.startPrank(prover);
    //     bondToken.approve(address(proofPool), type(uint256).max);
    //     vm.stopPrank();

    //     // Submit the task
    //     vm.startPrank(requester);
    //     TaskAssignment memory assignment = TaskAssignment({
    //         prover: prover,
    //         rewardToken: address(rewardToken),
    //         rewardAmount: 5 ether,
    //         liabilityWindow: 3600,
    //         liabilityToken: address(rewardToken),
    //         liabilityAmount: 5 ether,
    //         expiry: uint64(block.timestamp + 3600),
    //         signature: signature
    //     });
    //     bytes32 taskKey = proofPool.submitTask(
    //         instance,
    //         prover,
    //         address(rewardToken),
    //         5 ether,
    //         3600,
    //         address(rewardToken),
    //         5 ether,
    //         uint64(block.timestamp + 3600),
    //         signature
    //     );
    //     TaskStatus memory taskStatus = proofPool.readProofStatus(taskKey);
    //     vm.stopPrank();
        
    //     console2.log("The taskKey is:", vm.toString(taskKey));
    //     console2.log("Check if prover get the reward: ", rewardToken.balanceOf(prover));
    //     console2.log("Check if pool get the bond: ", bondToken.balanceOf(address(proofPool)));
    //     console2.log("Check task status: ", vm.toString(taskStatus.instance));
    //     console2.log("Check task status: ", taskStatus.prover, taskStatus.submittedAt, taskStatus.proven);

    // }

    function test_submitTask() public {

        // return keccak256(
        //     abi.encode(
        //         _instance,
        //         _rewardToken,
        //         _rewardAmount,
        //         _liabilityToken,
        //         _liabilityAmount,
        //         _expiry,
        //         _liabilityWindow
        //     )
        // );

        // bytes memory instance = abi.encodePacked(hex"31373031303733383636343637");
        // address _rewardToken = address(0xfDfd239c9dD30445d0e080Ecf055A5cc53456A72);
        // uint256 _rewardAmount = 100;
        // address _liabilityToken = address(0xfDfd239c9dD30445d0e080Ecf055A5cc53456A72);
        // uint256 _liabilityAmount = 100;
        // uint64 _expiry = 4777034;
        // uint64 _liabilityWindow = 36000;

        vm.startPrank(prover);
        // bytes32 digest = keccak256(
        //     abi.encode(
        //         instance,
        //         _rewardToken,
        //         _rewardAmount,
        //         _liabilityToken,
        //         _liabilityAmount,
        //         _expiry,
        //         _liabilityWindow
        //     )
        // );

        // console2.log("digest is:", vm.toString(digest));


// bytes32 digest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",
//                                             bytes32(uint256(uint160(adin))), 
//                                             bytes32(ticketNum))
// );

        // string memory _message = "hello world";

        // bytes32 digest = keccak256(abi.encodePacked("\u0019Ethereum Signed Message:\n11", _message));
        // (uint8 v, bytes32 r, bytes32 s) = vm.sign(proverPrivateKey, digest);
        // bytes memory signature = abi.encodePacked(r, s, v);

        // console2.log("digest is:", vm.toString(digest));
        // console2.log("v is:", vm.toString(v));
        // console2.log("r is:", vm.toString(r));
        // console2.log("s is:", vm.toString(s));
        // console2.log("signature is:", vm.toString(signature));
        // console2.log("proverPrivateKey is:", vm.toString(abi.encodePacked(proverPrivateKey)));
        console2.log("address is:", vm.addr(proverPrivateKey));
        // console2.log("recover result is:", digest.recover(signature));
        
        bytes32 hashedMsg = 0x4be1b2cc9677242a50e0c8e71f2eb9479399f1b04ccc3888729176bcc739f571;
        console2.log("hashedMsg is:", vm.toString(hashedMsg));

        bytes32 digest = keccak256(abi.encodePacked("\u0019Ethereum Signed Message:\n32", bytes.concat(hashedMsg)));
        console2.log("digest is:", vm.toString(digest));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(proverPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);
        console2.log("signature is:", vm.toString(signature));


        // bytes32 hash = keccak256("Signed by Alice");
        // (uint8 v, bytes32 r, bytes32 s) = vm.sign(alice, hash);
        // address signer = ecrecover(hash, v, r, s);
        // assertEq(alice.addr, signer); // [PASS]

        
        // console2.log("prover is:", prover);
        // console2.log("signature is:", vm.toString(signature));

        // console2.log("signature is:", vm.addr(uint256(bytes32(hex"db96b69680aee75d9b9b952b9cfb11bebef7c9f36a66147675d0219aa69306df"))));



        // address result = _hashAssignment(
        //     instance,
        //     _rewardToken,
        //     _rewardAmount,
        //     _liabilityWindow,
        //     _liabilityToken,
        //     _liabilityAmount,
        //     _expiry
        // ).recover(_signature);

        // console2.log("address is:", result);
        // console2.log("prover is:", prover.address);



        
        
        
    }


    // function test_proveTask() public {
        
    //     // Assume we have a proof which looks like this:
    //     bytes memory proof = hex"000000000000000000000000000000000000000000000004a27903c822133cec0000000000000000000000000000000000000000000000023a2e7b7459c4f39500000000000000000000000000000000000000000000000f468591e2ffd370080000000000000000000000000000000000000000000000000000d7db8f3b2ce20000000000000000000000000000000000000000000000083de1aedd80279c9a00000000000000000000000000000000000000000000000052a95d09cefa2396000000000000000000000000000000000000000000000006214884f862d834280000000000000000000000000000000000000000000000000000a42ee7bafacf0000000000000000000000000000000000000000000000069e874527995e809300000000000000000000000000000000000000000000000936b3c433c6f62d2c00000000000000000000000000000000000000000000000a2048d1a30930c91d0000000000000000000000000000000000000000000000000000a7eaa805164b00000000000000000000000000000000000000000000000be8d87419ff9c5ada000000000000000000000000000000000000000000000001fd8339c88a7da946000000000000000000000000000000000000000000000003cf01b8a9c9df6f790000000000000000000000000000000000000000000000000002a212ae8401f62cc7944a00c6c950e587b7146e3fb802d6faaf3713a5af62bb5f6de31c90febd2cc216187ea67b009b5190f10dda440502bdb11ad9996e0ef417ef88da2c755f083cbb909c3afbc82170a33c004a1a4c92514dfb34c6a2ae36e80b75bd00fb5326dfd92703ed9b3ab6cb73742c6bb7b53715ccb4c8eb6ce3966a28679bee92432a159042af9bc3c8606e5fc73af13c269f268b33ed43bbd168865ea10a9fd033303a0a5983fc5c7629e6a63d94b74be6a9a7d70552c817b572353a6d9000555e0963c34d8c5d4d8a0c634aec852d49e87097379cce27d9f3c9f28a01ec4ddac02f9bfbeaf0571e6cc911c59861c2f9e57a8ba34ae9251ce7f8a616278beec3c61603cdcca7636f51307a091e2194293f1110684e5e95a75fd6b3e5eb044693d518bc2af5be1022d8c88f5bc80e8ad95b930c4ffbe131648bea200e134b5279ab2f25f11fdf0e866b9729ae4add181a2a91229bd1fb77c37a0db4d0e6a523140b145637530e2abdfb1f0f507d1f1c7bcb98b676785761503bbfa33a3001e0971401e022d4f58302a22c7353dac5a439bc360afb9ebe47518e6a41228f7386ad172e94152ade06810368f42ee27aa1a40e582b2fbebd39a93fdd5f4ce5384b1e140da3b89e780447f77303771a29e5be98ef1ca2651f7bbb9bcfded848bce21c7920b5e110d2261c8512375841cea8f2995ad0f377e5fefba5a7c4e122205f14050bffdcece6b2af7807c1c24510a3ffeb7f41afcbd0f828978798537ebdcc966c0226446057d7743a79e58078f6fbb78160595f155736298c33c40a7b868732ed1b961acbbfaad327b6c8b1f43da2dc6417bb4bbd1883b267b431d698d83136031e97da47367ef6e13ecbda470c6409fbe10d83d191b2b6be3924238ee636ced01ee6b12bb458ac4933f3a7322d83a85759fa2b2a1bfb4dd7577964ac713db58217352dc516d22a742f8ebe18c1c1f15c9569016aa85e79a0e4698f78addc4ffb1e3f687a650acc27f83033fc57bd93fd15d430db3d7c9d907b5f2ecd4622e8041f84373a6ea89d676126b889267ec6cca18b79ea177ec712e8c7cf647c28c6f1182f387b60ef85b5d839087b9e297f6aa8c3c6ac997e38b863f74a8c5b170939301f5ebe347ce8cd57cd2ba6cce473c21b6a71c320c4ceefacfa0440f9ace24b11152ec80f8ba025dc483b6aec22fed90d3d3dbf1887d0b6b5d22a5c287055fc07244b4ca05487ad17c3ffed3981b81c71748baac228bfac7af1080842fdb42e1395ac2fe992f332774996e1d29ba9677cc5d786171961960cc69703e66a55cc08eb5ccd7fe1b2b67d168cf8503db7555c43b700eb95c65c65c90ec73021f326254991641d6dad346297fd78b4d2f82d2708ccd7d01e235b4bd71bc29eca269e10b377af356928f032259fd7c1aaaea15646e7a08e9b9be897f6b2c37d065c6625f0cc2298fd5c862272b36dd7eeb5cdb3187e127efb8d63a74b589110082fb90edffd759aaf17ebd11c516bf2f1c628db4e542c062adf617eb2aaa457e51fef1b4645b69c1d8fce09c52e0f33e764e6f2d5ce59ab5722661a22c5da5bc616f303c79c3ffe87ca72237e5997a56fef750635db7d13aa782189d252e2c326285c26964081fd0ca1f2514501f682f96f887686fe786d31edd9ee47ee07d64fb0c01aef4dccdaadb4ef02b4e79f02a1d224f11df7861b2c24b29af19ed4985078ec17b3f75407c2e06a6d4a9e40476fceec843c48b8e4aedbbaa161b088455dac9a0936e9b87683bbe26dc7a2cb6c5869c749c4de66310a6d764ea4ef46bd606619085711e25b57ad398a58297b50afea0fe0ab1472f34a26b93f974340f18266a80c96a103e2909545cd57dc78f1239cde93f76fb47630d67629bb62afa7fa5c6c181304c22d08cd31efe18935598387a8f42cd7992fa8c4fe98a162d5cf1a47e120e9a6d3a6455e11c658e4c7790f011a166074e3d18237f72c2f01d9eab231ad18eff01f55a1729fa6504fbdea48c6c5367dbd2234c6b1ed53edfd6d82905e950053f78c18372cb256782303f789d9e639bc47e1cad13529d86a4760a723cc9c26e6ebc398291d9b2b4aa7f0e1093dd2c92188056fb6e6022ae797b943e7081101bdd1cf8f575686825bd4c5a55a77cd1a7eb642156733f14831921f662d89d3252935a98ada18843d20afcc9eaac0c86f82e5235f0980180521f0b985fb6fed0a9593970f61527321cfb5eb9ba709316d98df236df641db89a39b3b6d1c5b9102305b0c6ba969bab39b017621ceb792e9e2b2d25dc554375ae68fbf07f021b01945c353fad83c6ff42d4192e8805a09bc21f1ce207ae7db4f434fbbfa662a9f08a442f78eb1160751abc7e5a5544678fcb1ff25d923518149f1258a5fa7b2b321fb393d8b32e77fe4ba8980538df5d60ae98d4ac49b6387717134d60cd29d6325f645a92e8c6d1c1288f6438697720c28165c9147a3571ae396fea65a0b6d5c256b80f14e5bfc7e9a14965490f8421bac53c6b81314f1606c10f49d630377ad21d75cc1aa4f77c56fe38ff385ff991a19c2907523c0907eec74a4fd950931f51c778804dc0d37581ddf62b2923bba393d50ded45c51a863968c15ea793f4f412953471760cae8745187c85387e0658554746bfc2b8988d00ec283cca6a6a248263eba6478fed99f89e0d07acfa1cfd31582a2b69540f9f953f1962bba5e50d81bab024ce41c1d695ba71a4e469ba8a9836ef4e3c92ec783c0b3204b00ffdf73188d7cf06dbd59f9e33f72b5e157f48a20f438202b008f84799093217e1d354b1c4f3244f81f59449e8bd18575df861640e3261f87ce629846fdcd3b89d1896d07ede0bb52d0ea25571cbc2b5332f820f7c41f70c0518fe6b71c302c270773ca0d3810095f52acebcb7bb1e805637d4019e5e5bb488e90424ca58ef64619774f2fd9bdafcaf4a42af9962dc87784f23abd5965ca6c2c81c7a32ac9acd7ecafb81dab9ca27fd229b554a16a5958ebfa9cc2fb122c6781a9cf5c2b5373a98199960e323d89bc1efcb577194d08e2d87a7de07cd07a383fa5b4cc6467759e58ad561cd93c8cdb8e3199651b0058c4b329ac211b6bec6c888b2e1911bfa9fa77267b2dd687a6767568010f0e30440446fff4fed6421e618af524c1add606c23d78560b7ed2bc0d9b84090a2fd8726d8ab4fb9548b3d5e68cd3a12dd111f1756427d806d290df0f20642ad665cbad6470162aad12dc3bba7de8bdd36b40acf40ae0bf2d9f3c72821bc627c9f83307be3b24d74a83a480151a4893025c53722d461c2717bd0d182ba0d07425f87cb1cb9c8b18d84283d30cc0271ee5f55061b4e189c32d100d9b3ef6d3bb10d7f251afa3ec5ca4f9964d5c7dc98e69fe6eb404e9fc071f26be9472e3ce9e3e54406e71a76330430c3fe2ccb94458535222b9efd76d992149c74f4dfbce89ab12c95b0223c2116110d42543f0e2ffeca29ebe58b1d76f0ec322612f608574a1ac7d2d8377b9feb16fb77941bbaa1551dd28c01994095301ede6eaf33461d0b2dc609af5859949b6d2ab90dd9b85f86845292aa4ac335b0678de40b123d2e9c18d60bef27721d86c4f0788423082c758b89f6e58dc41ac2199fdd936ce21c3433c27369bd773677f27e67240bd02a916f9b3c875db6d5f2cf72bf47fae1298dfe2a6837037ef6ae764dadb14be8b7eb72c2033c69875a3011b899abf8037fa4a4e07569cf1fb366f310c514ea2a1bb4622ea8de3d630aa0af3bdb1bad354cd9dba77aae02b6da930e2bf965443787861024dd08a94ad6d16e31711056fd4c0523b6faf25c678fde5f75fe94c2a44abe5e79a454e0ac28e205b30d6f6818d38ea5517dc4a0f781bd7ba3c7da70b282a0ab4e27e1ea654c711584ec8902fe1978022ebefcf4b754d4b882ff875febbfcd208b4d866b8ee9303e44252a258141f43b317793285a677db9798a4e009c9d661cfc931a9a365af25db79195f8da28f29f9a1f56f6fec3b4e08d5bf48508934213c3250fffd33b211198a127aebdfcecb19adf1b756c339577dd0da75386f82a3f42ae1698b6be31b5b6fd66b651eda6c83267e2aee6f1cdcccd85447dfd6b10e224e08d05c4495071f22dd4d0d31ce99a807002c6383db46aee0e3b6df06cd31300bb0ffde8aac03d1f35f5763840e6ce3644c8746c8673b682d623db09b1436863a98c95bc9e028c4444bdb54e0208405d39a27c6a5729576476677265b7c68722ea427c7000f2db7160bf889e33d4f59aa0e0bbd55a9e806c0cdcd429c9785d7eb29ee494b7505d882d8493b24e0cb77af9425b0bb121cafa9175b20f791c5d02820ba5c6fac1c46725457d27c80f9cf5027e30b638eb58e904e46c8d5782e859ad61ef550540c0c1b73afd9267ea33bc6d74c2f4a3a54540f592fe495fdbda06f6860a7f93e0c656c36766bbd2cd1b8178c0d3edf5f860cf0fc66fd3cca3f20c359a65d7fe62267d06a4e4c4aead49db45c6b1e13e55b713d27d3e4729dd82466e45d22c3e018720338700378133da093249358e1b335d37e77812631db6dedff73448ecfdf1b8637f4f837870a158d5e90b82626603abf7733ba675c14674d35d4f1be807b1cccc4dcd267cb1a4db2540f0afdee3160dbaaf7a3015acdf90c14b47055ab091bb1d3c1790f53b313dbdbaed50e183e284092663c71113a1f5f06d6c78599f22f6eb7b43837b77c957414ba803dc4fc79e1e3e3597d2e528e03e264b00bbf7105335881f0b3debcab2f896894ab65209a4e2369fcf3a3cec45c771b58d33e872dc8e04a5488f8ccc8ad1e90439966e1a85148c4f213646274435a34c13db81d19e6afaf63cb9ca40ec7c9fd88078c0fa41aa45c817df40ca88fd07a2248f1d101c2abbc9182b0f2cbdf57f24511868a283947076b8b0ad1e09a58421522bb9b0d9cd37264391517736c7e3911508e67ce0fc9bb371718c06cf8526c2f0037d317c7d8260a91e065591722e7241d1a588b9470eac96815eec7ae7152ecae902626a867a8ef7e9d82a14e0fe8b5aa951238cb5ba7f060183806c598ec1f29056306d6159348ed917b4151febfe2a197a80e1822e916dac60e70676befb93dae9b298e8cd00746689e3fdd815194095bb46bc650337ae8a0c68a7c297726532c86019528e7ff377ec472eb31e944a2bd16e394f26ed6d4cf570d54b562172f413c15c43be8cdf97060a47601f7e527fb9835b1e4528ffad6fc29cdd7e7623b22322cfab0c1a7a16327f104f580c1f85f1238f3786922d0e67476f17396e4e34757182f48c24bc05dcb0132b29233d01da09dcb547a553a6f32b975c978aefb21b91c384a4c055e707534df72f180e72bf789a6ad49a716495cc9c18ead95940146";

    //     bytes memory instance = LibBytesUtils.slice(proof, 0, 32);

    //     // Start the signature
    //     vm.startPrank(prover);
    //     bytes32 digest = keccak256(
    //         abi.encode(
    //             instance,
    //             address(rewardToken),
    //             5 ether,
    //             block.timestamp + 3600
    //         )
    //     );
    //     (uint8 v, bytes32 r, bytes32 s) = vm.sign(proverPrivateKey, digest);
    //     bytes memory signature = abi.encodePacked(r, s, v);
    //     vm.stopPrank();

    //     // ERC20 approval by requester
    //     vm.startPrank(requester);
    //     rewardToken.approve(address(proofPool), type(uint256).max);
    //     vm.stopPrank();
    //     // ERC20 approval by Prover
    //     vm.startPrank(prover);
    //     bondToken.approve(address(proofPool), type(uint256).max);
    //     vm.stopPrank();

    //     // Submit the task
    //     vm.startPrank(requester);
    //     TaskAssignment memory assignment = TaskAssignment({
    //         prover: prover,
    //         rewardToken: address(rewardToken),
    //         rewardAmount: 5 ether,
    //         liabilityWindow: 3600,
    //         liabilityToken: address(rewardToken),
    //         liabilityAmount: 5 ether,
    //         expiry: uint64(block.timestamp + 3600),
    //         signature: signature
    //     });
    //     bytes32 taskKey = proofPool.submitTask(
    //         instance, 
    //         prover,
    //         address(rewardToken),
    //         5 ether,
    //         3600,
    //         address(rewardToken),
    //         5 ether,
    //         uint64(block.timestamp + 3600),
    //         signature
    //     );
    //     vm.stopPrank();
        

    //     // Submit the proof
    //     proofPool.proveTask(taskKey, proof);
    //     TaskStatus memory taskStatus = proofPool.readProofStatus(taskKey);

    //     console2.log("The taskKey is:", vm.toString(taskKey));
    //     console2.log("Check if prover get the reward: ", rewardToken.balanceOf(prover));
    //     console2.log("Check if pool returned the bond: ", bondToken.balanceOf(address(proofPool)));
    //     console2.log("Check task status: ", vm.toString(taskStatus.instance));
    //     console2.log("Check task status: ", taskStatus.prover, taskStatus.submittedAt, taskStatus.proven);
    // }

}