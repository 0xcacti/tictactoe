// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


import "forge-std/Test.sol";
import "src/TicTacToe.sol";
import {Game} from "src/Game.sol";


contract TicTacToeTest is Test {

    TicTacToe t;
    address playerZero;
    address playerOne; 

    function setUp() public {
        t = new TicTacToe();
        playerZero = 0x4675C7e5BaAFBFFbca748158bEcBA61ef3b0a263;
        playerOne = 0xFeebabE6b0418eC13b30aAdF129F5DcDd4f70CeA;
    }

    function testNewGameHasProperInitialState() public {
        uint256 gameId = t.createNewGame(playerZero, playerOne);
        (uint256 playerZeroAndGame, address inGamePlayerOne) = t.retrieveAllGameInfo(gameId);
        assertEq(playerZeroAndGame >> 160, 0);
        assertEq(address(uint160(playerZeroAndGame)), playerZero);
        assertEq(inGamePlayerOne, playerOne);
    }

    function testRejectMoveOutOfBounds() public {
        uint256 gameId = t.createNewGame(playerZero, playerOne);
        vm.startPrank(playerZero);
        vm.expectRevert(Game.IllegalMove.selector);
        t.takeTurn(gameId, 9);
        vm.stopPrank();
    }

    function testRejectMoveToOccupiedSpace() public {
        uint256 gameId = t.createNewGame(playerZero, playerOne);
        vm.startPrank(playerZero);
        t.takeTurn(gameId, 8);
        vm.stopPrank();

        vm.startPrank(playerOne);
        vm.expectRevert(Game.IllegalMove.selector);
        t.takeTurn(gameId, 8);
        vm.stopPrank();
    }

    function testRejectMoveByWrongPlayer() public {
        uint256 gameId = t.createNewGame(playerZero, playerOne);
        vm.startPrank(playerOne);
        vm.expectRevert(TicTacToe.NotYourTurn.selector);
        t.takeTurn(gameId, 8);
        vm.stopPrank();
    }

    function testRejectMoveByInvalidPlayer() public {
        uint256 gameId = t.createNewGame(playerZero, playerOne);
        vm.startPrank(address(0));
        vm.expectRevert(TicTacToe.InvalidPlayer.selector);
        t.takeTurn(gameId, 8);
        vm.stopPrank();
    }

    function testRejectMoveAfterGameEnd() public {
        uint256 gameId = t.createNewGame(playerZero, playerOne);
        vm.prank(playerZero);
        t.takeTurn(gameId, 0);
        vm.prank(playerOne);
        t.takeTurn(gameId, 4);
        vm.prank(playerZero);
        t.takeTurn(gameId, 1);
        vm.prank(playerOne);
        t.takeTurn(gameId, 5);
        vm.prank(playerZero);
        t.takeTurn(gameId, 2);
        vm.prank(playerOne);
        vm.expectRevert(Game.GameOver.selector);
        t.takeTurn(gameId, 6);
    }

    function testSwitchTurnSucceeds() public {

        // set turn bits
        uint256 playerZerosTurn = 0;
        uint256 playerOnesTurn = uint256(0x01 << 72);
          
        // create game 
        uint256 gameId = t.createNewGame(playerZero, playerOne);
        uint256 gameBoard = t.retrieveGame(gameId);

        // take turns and check that turn bit flips
        vm.prank(playerZero);
        t.takeTurn(gameId, 8);
        gameBoard = t.retrieveGame(gameId);
        assertEq(isolateTurnByte(gameBoard), playerOnesTurn);

        vm.prank(playerOne);
        t.takeTurn(gameId, 7);
        gameBoard  = t.retrieveGame(gameId);
        assertEq(isolateTurnByte(gameBoard), playerZerosTurn);

        vm.prank(playerZero);
        t.takeTurn(gameId, 6);
        gameBoard  = t.retrieveGame(gameId);
        assertEq(isolateTurnByte(gameBoard), playerOnesTurn);

    }

    // helper function 
    function isolateTurnByte(uint256 gameBoard) public pure returns (uint256 turn){
        uint256 mask = uint256(0xff << 72);   
        return (gameBoard & mask);
    }

    // your game board 
        // 0x00 00 00 | 00 00 00 | 00 00 00 | 00 00 00
        //         turnByte : 0 => playerZero's turn, 1 => playerOnes turn 
        //       winnerByte : 0 => No Winner, 1 => playerZero, 2 => playerOne, 3 => tie game



}
