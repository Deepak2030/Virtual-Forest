// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

//import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
//import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract VirtualForest is ERC721URIStorage /*, VRFConsumerBaseV2*/  {

    // Errors
    error VirtualForest__MoreEthRequired();
    error VirtualForest__SeedDead();
    error VirtualForest__NoNeedToWaterTree();

    // Libraries
    using Counters for Counters.Counter;

    // State Variables
    // Smart Contract variables
    uint private immutable i_totalDays = 14; /* Variable is set to 14 days since, upon the 15th day it'll become a tree */
    uint private immutable i_minEthRequired = 0.0001 ether;
    uint private seedId;

    // ERC721 Variables
    Counters.Counter private _tokenIdCounter;

    /*
    //Variables used by constructor
    bytes32 private immutable i_keyHash;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    //Variables used by chainlink oracles
    uint16 private constant REQUEST_CONFIRMATIONS = 1;
    uint32 private constant NUM_WORDS = 1;
    uint private indexRandomTreeFacts;
    */

    // Events
    /* event RequestFulfilled(uint256[] randomWords); */

    // Type Declarations
    enum Stage {
        seed,
        sapling,
        tree
    }

    struct location {
        uint128 lattitude;
        uint128 longitude;
    }

    location[] public seedLocation;
    uint[] private userSeeds;

    string[] public randomTreeFacts = [
        "Trees improve water quality.",
        "Trees block noise by reducing sound waves.",
        "Tree rings can predict climate change.",
        "Trees help prevent soil erosion.",
        "Some trees can live for thousands of years."
    ];

    string[] private IpfsUri = [
        "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/seed.json",
        "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/purple-sprout.json",
        "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/purple-blooms.json"
    ];

    // Mappings to get data from user
    mapping(address => uint) public userSeedCount;
    mapping(address => uint) public totalManureBags;

    // Mapping to store multiple variables pointing to a same location
    mapping(uint => location[]) public seedIdToSeedLocation;
    mapping(address => uint[]) public userToSeedId;

    // Mappings to get seed data
    mapping(uint => bool) public seedState;
    mapping(uint => uint) public seedTimestamp;
    mapping(uint => Stage) public seedStage;
    mapping(uint => uint) public seedDaysCounter;
    mapping(uint => uint) private seedIdToTokenId;

    // Constructor
    constructor(/*address vrfCoordinator, bytes32 keyHash, uint64 subscriptionId, uint32 callbackGasLimit*/) /* VRFConsumerBaseV2(vrfCoordinator) */ 
    ERC721(
            "TreeNFTs",
            "TNFT"
        )
    {
        /*i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_keyHash = keyHash;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;*/
    }

    //Functions

    /*  @dev: This function buys seeds for (msg.sender) and adds it to their seed bag(userSeedCount) */
    function getSeed() public payable {
        if (msg.value < i_minEthRequired) {
            revert VirtualForest__MoreEthRequired();
        }
        userSeedCount[msg.sender] += uint(msg.value / i_minEthRequired);
    }

    /*  @dev: This function buys manure for (msg.sender) and adds it to their manure bag(totalManureBags) */
    function getManureBags() public payable {
        if (msg.value < i_minEthRequired) {
            revert VirtualForest__MoreEthRequired();
        }
        totalManureBags[msg.sender] += uint(msg.value / i_minEthRequired);
    }

    /*
     * @dev:      This function is used to plant a seed to any desired location and upon plating a random fact about trees is
     *            generated and it also updates the various parameters of the seed in the mappings.
     * @refactor: This code is refactored to generate randomNumber for the randomfacts with the help of abi.encode(args)
     *            rather than using chainlink oracles to save gas
     */
    function plantSeed(
        uint128 _lattitude,
        uint128 _longitude
    ) public returns (string memory) {
        require(userSeedCount[msg.sender] > 0);
        seedId++;
        seedIdToSeedLocation[seedId].push(location(_lattitude, _longitude));
        seedTimestamp[seedId] = block.timestamp;
        seedState[seedId] = true;
        userToSeedId[msg.sender].push(seedId);
        seedDaysCounter[seedId] = 0;
        userSeedCount[msg.sender]--;
        /* uint requestId = i_vrfCoordinator.requestRandomWords(
            i_keyHash,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        ); */
        return
            randomTreeFacts [uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, seedId))) % 5];
        //return randomTreeFacts[indexRandomTreeFacts];
    }

    /* *
     * @dev: This function is used to complete the requestRandomness Function and generate randomness with the help of chainlink oracles
     * @refactor: Its not used to save gas instead abi.encodepacked is used to generate randomness
     */
    /* function fulfillRandomWords(uint requestId, uint[] memory randomWords) internal override {
        indexRandomTreeFacts = randomWords[0] % randomTreeFacts.length;
    } */

    /* *
     * @dev: This function is used to water the plant and if the plant grows to a different stage a Dynamic NFT is minted
     *       various checks are done to see if the seed is alive and its stage is updated accordingly
     */
    function waterPlant(uint _seedId) public {
        require(_seedId > 0 && _seedId <= seedId);
        require(
            (seedStage[_seedId] == Stage.seed)  ||
            (seedStage[_seedId] == Stage.sapling)
        );
        require(block.timestamp - seedTimestamp[_seedId] > 84600);

        if (seedDaysCounter[_seedId] == i_totalDays) {
            seedStage[_seedId] = Stage.tree;
            revert VirtualForest__NoNeedToWaterTree();
        }
        if (block.timestamp > 86400 + seedTimestamp[_seedId]) {
            seedState[_seedId] = false;
            revert VirtualForest__SeedDead();
        }
        if (
            seedDaysCounter[_seedId] >= 2 &&
            seedDaysCounter[_seedId] < i_totalDays
        ) {
            seedStage[_seedId] = Stage.sapling;
        }

        seedTimestamp[_seedId] = block.timestamp;
        seedDaysCounter[_seedId]++;
        userSeedCount[msg.sender]++;

        if (userSeedCount[msg.sender] == 1) {
            safeMint(msg.sender, _seedId);
        }
        if (
            seedDaysCounter[_seedId] >= 2 &&
            seedDaysCounter[_seedId] < i_totalDays
        ) {
            uint8 newVal = uint8(seedStage[_seedId]) + 1;
            string memory newUri = IpfsUri[newVal];
            _setTokenURI(seedIdToTokenId[_seedId], newUri);
        }
        if (seedDaysCounter[_seedId] >= i_totalDays) {
            uint8 newVal = uint8(seedStage[_seedId]) + 1;
            string memory newUri = IpfsUri[newVal];
            _setTokenURI(seedIdToTokenId[_seedId], newUri);
        }
    }

    /*  @dev: This function is used to mint NFT upon successful growth of the plant */
    function safeMint(address _to, uint _seedId) internal {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(_to, tokenId);
        _setTokenURI(tokenId, IpfsUri[0]);
        seedIdToTokenId[_seedId] = tokenId;
    }

    /*  @dev: This function is used to add manure to the plant which increases its growth by 1 day*/
    function addManure(uint _seedId) public {
        require(_seedId > 0 && _seedId <= seedId);
        require(totalManureBags[msg.sender] > 0);
        require(seedState[_seedId]);
        require(seedDaysCounter[_seedId] < i_totalDays);

        if (block.timestamp > 86400 + seedTimestamp[_seedId]) {
            seedState[_seedId] = false;
            revert VirtualForest__SeedDead();
        }

        seedDaysCounter[_seedId]++;

        if (seedDaysCounter[_seedId] == 1) {
            seedStage[_seedId] = Stage.sapling;
            uint8 newVal = uint8(seedStage[_seedId]) + 1;
            string memory newUri = IpfsUri[newVal];
            _setTokenURI(seedIdToTokenId[_seedId], newUri);
        }
        if (seedDaysCounter[_seedId] == i_totalDays) {
            seedStage[_seedId] = Stage.tree;
            uint8 newVal = uint8(seedStage[_seedId]) + 1;
            string memory newUri = IpfsUri[newVal];
            _setTokenURI(seedIdToTokenId[_seedId], newUri);
        }
    }

    /*  @dev: returns the time left to water the plant */
    function timeLeftToWaterInSeconds(uint _seedId) public view returns (uint) {
        require(_seedId > 0 && _seedId <= seedId);
        require(seedStage[_seedId] != Stage.tree);

        if (!seedState[_seedId]) {
            revert VirtualForest__SeedDead();
        }

        return (block.timestamp - seedTimestamp[_seedId]);
    }

    /*  @dev: returns the stage of the plant */
    function getStageOfPlant(uint _seedId) public view returns (Stage) {
        require(_seedId > 0 && _seedId <= seedId);
        if (!seedState[_seedId]) {
            revert VirtualForest__SeedDead();
        }

        return seedStage[_seedId];
    }

    /*  @dev: returns location of the plant with the given seedId */
    function getLocation(uint _seedId) public view returns (location[] memory) {
        require(_seedId > 0 && _seedId <= seedId);
        if (!seedState[_seedId]) {
            revert VirtualForest__SeedDead();
        }

        return seedIdToSeedLocation[_seedId];
    }

    /*  @dev: returns the time left to become tree */
    function timeLeftToBecomeTreeInSeconds(
        uint _seedId
    ) public view returns (uint) {
        require(_seedId > 0 && _seedId <= seedId);
        if (!seedState[_seedId]) {
            revert VirtualForest__SeedDead();
        }

        return (1209600 - block.timestamp - seedTimestamp[_seedId]);
    }
}
