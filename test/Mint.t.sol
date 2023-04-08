// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/TicTacToe.sol";
import "test/Utils.sol";
import {Game} from "src/Game.sol";

contract InvalidPlayTest is Test {
    TicTacToe game;
    address playerZero;
    address playerOne;
    Utils utils;

    function setUp() public {
        game = new TicTacToe();
        playerZero = 0x4675C7e5BaAFBFFbca748158bEcBA61ef3b0a263;
        playerOne = 0xFeebabE6b0418eC13b30aAdF129F5DcDd4f70CeA;
        utils = new Utils(game, playerZero, playerOne);
    }

    function testMetadata() public {
        uint256 gameId = game.createNewGame(playerZero, playerOne);
        uint256[9] memory turns = [uint256(1), 0, 3, 2, 4, 5, 6, 7, 8];
        utils.playGame(gameId, turns);
        string memory meow = game.tokenURI(gameId);
        console2.log(meow);
    }
}
