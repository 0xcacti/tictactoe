// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/TicTacToe.sol";
import {Game} from "src/Game.sol";

contract GaveOverTest is Test {
    TicTacToe t;
    address playerZero;
    address playerOne;

    function setUp() public {
        t = new TicTacToe();
        playerZero = 0x4675C7e5BaAFBFFbca748158bEcBA61ef3b0a263;
        playerOne = 0xFeebabE6b0418eC13b30aAdF129F5DcDd4f70CeA;
    }

    function testRejectMoveAfterGameEnd() public {
        uint256 gameId = t.createNewGame(playerZero, playerOne);
        uint256[5] memory turns = [uint256(0), 3, 1, 4, 2];
        playGame(gameId, turns);

        vm.prank(playerOne);
        vm.expectRevert(Game.GameOver.selector);
        t.takeTurn(gameId, 5);
    }

    function testGameOverDraw() public {
        uint256 gameId = t.createNewGame(playerZero, playerOne);
        uint256[9] memory turns = [uint256(1), 0, 3, 2, 4, 5, 6, 7, 8];
        playGame(gameId, turns);

        uint256 gameBoard = t.retrieveGame(gameId);
        assertEq(isolateWinnerByte(gameBoard), 3);
    }

    function testRowZeroWin() public {
        uint256 gameId = t.createNewGame(playerZero, playerOne);
        uint256[5] memory turns = [uint256(0), 3, 1, 4, 2];
        playGame(gameId, turns);
        uint256 gameBoard = t.retrieveGame(gameId);
        uint256 rowZero = gameBoard & 0xffffff;
        assertEq(rowZero, 0x010101);
        assertEq(isolateWinnerByte(gameBoard), 1);
    }

    function testRowOneWin() public {
        uint256 gameId = t.createNewGame(playerZero, playerOne);
        uint256[5] memory turns = [uint256(3), 0, 4, 1, 5];
        playGame(gameId, turns);
        uint256 gameBoard = t.retrieveGame(gameId);
        uint256 rowOne = (gameBoard >> 24) & 0xffffff; 
        assertEq(rowOne, 0x010101);
        assertEq(isolateWinnerByte(gameBoard), 1);

    }

    function testRowTwoWin() public {
        uint256 gameId = t.createNewGame(playerZero, playerOne);
        uint256[5] memory turns = [uint256(6), 0, 7, 1, 8];
        playGame(gameId, turns);
        uint256 gameBoard = t.retrieveGame(gameId);
        uint256 rowTwo = (gameBoard >> 48) & 0xffffff; 
        assertEq(rowTwo, 0x010101);
        assertEq(isolateWinnerByte(gameBoard), 1);
    }

    function testColZeroWin() public {
        uint256 gameId = t.createNewGame(playerZero, playerOne);
        vm.prank(playerZero);
        uint256[5] memory turns = [uint256(0), 1, 3, 4, 6];
        playGame(gameId, turns);
        uint256 gameBoard = t.retrieveGame(gameId);
        uint256 colZero = (gameBoard) & 0x0000ff0000ff0000ff; 
        assertEq(colZero, 0x000001000001000001);
        assertEq(isolateWinnerByte(gameBoard), 1);
    }

    function testColOneWin() public {
        uint256 gameId = t.createNewGame(playerZero, playerOne);
        uint256[5] memory turns = [uint256(1), 0, 4, 5, 7];
        playGame(gameId, turns);
        uint256 gameBoard = t.retrieveGame(gameId);
        uint256 colOne = (gameBoard >> 8) & 0x0000ff0000ff0000ff; 
        assertEq(colOne, 0x000001000001000001);
        assertEq(isolateWinnerByte(gameBoard), 1);
    }

    function testColTwoWin() public {
        uint256 gameId = t.createNewGame(playerZero, playerOne);
        uint256[5] memory turns = [uint256(2), 0, 5, 7, 8];
        playGame(gameId, turns);
        uint256 gameBoard = t.retrieveGame(gameId);
        uint256 colOne = (gameBoard >> 16) & 0x0000ff0000ff0000ff; 
        assertEq(colOne, 0x000001000001000001);
        assertEq(isolateWinnerByte(gameBoard), 1);
    }

    function testDiagZeroWin() public {
        uint256 gameId = t.createNewGame(playerZero, playerOne);
        uint256[5] memory turns = [uint256(0), 1, 4, 5, 8];
        playGame(gameId, turns);
        uint256 gameBoard = t.retrieveGame(gameId);
        uint256 diagZero = (gameBoard & 0xff000000ff000000ff);
        assertEq(diagZero, 0x010000000100000001);
        assertEq(isolateWinnerByte(gameBoard), 1);
    }

    function testDiagOneWin() public {
        uint256 gameId = t.createNewGame(playerZero, playerOne);
        uint256[5] memory turns = [uint256(2), 1, 4, 5, 6];
        playGame(gameId, turns);
        uint256 gameBoard = t.retrieveGame(gameId);
        uint256 diagZero = (gameBoard & 0x0000ff00ff00ff0000);
        assertEq(diagZero, 0x000001000100010000);
        assertEq(isolateWinnerByte(gameBoard), 1);
    }

    function playGame(uint256 gameId, uint256[5] memory turns) public {
        address player;
        for (uint256 i = 0; i < turns.length; i++) {
            player = (isolateTurnByte(t.retrieveGame(gameId)) == 0) ? playerZero : playerOne;
            vm.prank(player);
            t.takeTurn(gameId, turns[i]);
        }
    }

    function playGame(uint256 gameId, uint256[9] memory turns) public {
        address player;
        for (uint256 i = 0; i < turns.length; i++) {
            player = (isolateTurnByte(t.retrieveGame(gameId)) == 0) ? playerZero : playerOne;
            vm.prank(player);
            t.takeTurn(gameId, turns[i]);
        }
    }


    function isolateWinnerByte(uint256 gameBoard) public pure returns (uint256 winner) {
        uint256 mask = uint256(0xff << 80);
        return (gameBoard & mask) >> 80;
    }
    
    function isolateTurnByte(uint256 gameBoard) public pure returns (uint256 turn) {
        uint256 mask = uint256(0xff << 72);
        return (gameBoard & mask) >> 72;
    }

}
