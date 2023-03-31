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

    function testRejectMoveAfterGameEnd() public {
        uint256 gameId = game.createNewGame(playerZero, playerOne);
        uint256[6] memory turns = [uint256(0), 3, 1, 4, 2, 5];
        vm.expectRevert(Game.GameOver.selector);
        utils.playGame(gameId, turns);
    }

    function testRejectMoveOutOfBounds() public {
        uint256 gameId = game.createNewGame(playerZero, playerOne);
        uint256[1] memory turns = [uint256(9)];
        vm.expectRevert(Game.IllegalMove.selector);
        utils.playGame(gameId, turns);
    }

    function testRejectMoveToOccupiedSpace() public {
        uint256 gameId = game.createNewGame(playerZero, playerOne);
        uint256[2] memory turns = [uint256(0), 0];
        vm.expectRevert(Game.IllegalMove.selector);
        utils.playGame(gameId, turns);
    }

    function testRejectMoveByWrongPlayer() public {
        uint256 gameId = game.createNewGame(playerZero, playerOne);
        vm.startPrank(playerOne);
        vm.expectRevert(TicTacToe.NotYourTurn.selector);
        game.takeTurn(gameId, 8);
        vm.stopPrank();
    }

    function testRejectMoveByInvalidPlayer() public {
        uint256 gameId = game.createNewGame(playerZero, playerOne);
        vm.startPrank(address(0));
        vm.expectRevert(TicTacToe.InvalidPlayer.selector);
        game.takeTurn(gameId, 8);
        vm.stopPrank();
    }
}
