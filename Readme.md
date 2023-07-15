# Virtual Forest Smart Contract

The Virtual Forest Smart Contract is a web-based game that allows players to grow a virtual forest while contributing to real-world tree plantation. Each day, players receive one seed that they can plant anywhere on a virtual map. The game also provides random information about nature when a seed is planted, raising awareness among players. The ultimate goal is to grow the planted seed into a mature tree, which can be minted as a Non-Fungible Token (NFT).

## Game Mechanics

1. **Seed Planting**: Each day, players receive one seed that can be planted anywhere on the virtual map.
2. **Watering**: After planting a seed, it must be watered within 24 hours. Failure to water the seed each day will result in its death.
3. **Growth Stages**: After two days of proper watering, the seed grows into a sapling. It takes a total of 15 days for the sapling to mature into a tree.
4. **Minting NFT**: Once a tree reaches maturity, it no longer requires watering and can be minted as an NFT.
5. **Random Nature Facts**: When planting a seed, the game provides players with a random fact about nature, promoting awareness.

## Additional Features

1. **Purchasing Seeds**: Players can purchase additional seeds to plant more trees in the virtual forest.
2. **Using Manure**: Players have the option to use manure, which reduces the growth time of a seed by one day.
3. **Unlimited Water**: Water is an unlimited asset in the game, ensuring players can water their trees without restrictions.
4. **Owner Information**: Players can view the owner of a particular plant.
5. **Watering Others' Plants**: Players can choose to water other players' plants, contributing to the growth of the virtual forest.

## Smart Contract Functions

The Virtual Forest Smart Contract provides the following functions:

- `plantTree()`: Allows a player to plant a seed on the virtual map.
- `getTimeToTree()`: Retrieves the time left for a planted seed to become a tree.
- `getManure()`: Allows a player to obtain manure.
- `waterTree()`: Enables a player to water their planted tree.
- `addManure()`: Allows a player to add manure to reduce the growth time of a seed by one day.
- `getTreeLocation()`: Retrieves the location of a specific tree.
- `showStage()`: Shows the current growth stage (plant, sapling, or tree) of a planted seed.
- `generateDynamicNFT()`: Generates a dynamic NFT for a matured tree.
- `getTimeToRewater()`: Retrieves the time left to rewater a planted seed.
- `getSeed()`: Provides a player with one seed each day.

These functions facilitate the gameplay and interaction with the virtual forest.

Feel free to explore and modify the Virtual Forest Smart Contract to create an engaging and environmentally-conscious gaming experience!