// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/TicTacToe.sol";
import "test/Utils.sol";
import {Game} from "src/Game.sol";

contract MintTest is Test {
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
    function testSingleSidedMintMetadata() public {
        uint256 gameID = game.createNewGame(playerZero, playerOne);
        uint256[9] memory turns = [uint256(1), 0, 3, 2, 4, 5, 6, 7, 8];
        utils.playGame(gameID, turns);
        game.mint{value: 0.005 ether}(gameID, 0);
        uint256 tokenID = (gameID << 160) | uint256(uint160(playerZero));
        string memory metadata = game.tokenURI(tokenID);
        console2.log(metadata);
    }

    // test return metadata matches pre-calculated base64 encoded string for double sided mint
    function testDoubleSidedMintMetadata() public {
        uint256 gameID = game.createNewGame(playerZero, playerOne);
        uint256[9] memory turns = [uint256(1), 0, 3, 2, 4, 5, 6, 7, 8];
        utils.playGame(gameID, turns);
        game.mintForBothPlayers{value: 0.01 ether}(gameID);
        uint256 tokenID = (gameID << 160) | uint256(uint160(playerZero));
        string memory playerZeroMetadata = game.tokenURI(tokenID);
        console2.log(playerZeroMetadata);
        console2.log();
        tokenID = (gameID + 1 << 160) | uint256(uint160(playerOne));
        string memory playerOneMetadata = game.tokenURI(tokenID);
        console2.log(playerOneMetadata);
    }

    // test minting fails if game is not over for single and double sided mins
    function testMintingRejectBeforeGameOver() public {
        uint256 gameID = game.createNewGame(playerZero, playerOne);
        uint256[8] memory turns = [uint256(1), 0, 3, 2, 4, 5, 6, 7];
        utils.playGame(gameID, turns);
        vm.expectRevert(TicTacToe.GameNotOver.selector);
        game.mint{value: 0.005 ether}(gameID, 0);
    }

    // test minting fails if payment is too low for single and double sided mints
    function testMintingRejectLowPayment() public {
        uint256 gameID = game.createNewGame(playerZero, playerOne);
        uint256[9] memory turns = [uint256(1), 0, 3, 2, 4, 5, 6, 7, 8];
        utils.playGame(gameID, turns);
        vm.expectRevert(TicTacToe.IncorrectPayment.selector);
        game.mint{value: 0.004 ether}(gameID, 0);

        gameID = game.createNewGame(playerZero, playerOne);
        utils.playGame(gameID, turns);
        vm.expectRevert(TicTacToe.IncorrectPayment.selector);
        game.mintForBothPlayers{value: 0.009 ether}(gameID);
    }
}
