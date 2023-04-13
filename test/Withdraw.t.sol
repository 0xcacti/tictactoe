// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/TicTacToe.sol";
import "test/Utils.sol";
import {Game} from "src/Game.sol";

contract WithdrawTest is Test {
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

    // test return metadata matches pre-calculated base64 encoded string for single sided mint
    function testMetadata() public {
        uint256 gameID = game.createNewGame(playerZero, playerOne);
        uint256[9] memory turns = [uint256(1), 0, 3, 2, 4, 5, 6, 7, 8];
        utils.playGame(gameID, turns);
        console.log(gameID);
        uint256 tokenID = (gameID << 160) | uint256(uint160(playerZero));
        string memory meow = game.tokenURI(tokenID);
        console2.log(meow);
    }

    // test return metadata matches pre-calculated base64 encoded string for double sided mint

    // test minting fails if game is not over for single and double sided mins

    // test minting fails if payment is too low for single and double sided mints

    // test tokenID is calculated correctly for single sided mint

    // test tokenIDs are calculated correctly for double sided mint

    
}
