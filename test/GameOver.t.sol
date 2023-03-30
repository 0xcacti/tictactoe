// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/TicTacToe.sol";
import {Game} from "src/Game.sol";

contract GaveOverTest is Test {
    TicTacToe t;
    address playerZero;
    address playerOne;
    uint256 gameIdTest;

    function setUp() public {
        t = new TicTacToe();
        playerZero = 0x4675C7e5BaAFBFFbca748158bEcBA61ef3b0a263;
        playerOne = 0xFeebabE6b0418eC13b30aAdF129F5DcDd4f70CeA;
    }

    function testRejectMoveAfterGameEnd() public {
        uint256 gameId = t.createNewGame(playerZero, playerOne);
        vm.prank(playerZero);
        t.takeTurn(gameId, 0);
        vm.prank(playerOne);
        t.takeTurn(gameId, 3);

        vm.prank(playerZero);
        t.takeTurn(gameId, 1);

        vm.prank(playerOne);
        t.takeTurn(gameId, 4);

        vm.prank(playerZero);
        t.takeTurn(gameId, 2);

        vm.prank(playerOne);
        vm.expectRevert(Game.GameOver.selector);
        t.takeTurn(gameId, 5);
    }

    function testGameOverDraw() public {
        uint256 gameId = t.createNewGame(playerZero, playerOne);

        vm.prank(playerZero);
        t.takeTurn(gameId, 1);

        vm.prank(playerOne);
        t.takeTurn(gameId, 0);

        vm.prank(playerZero);
        t.takeTurn(gameId, 3);

        vm.prank(playerOne);
        t.takeTurn(gameId, 2);

        vm.prank(playerZero);
        t.takeTurn(gameId, 4);

        vm.prank(playerOne);
        t.takeTurn(gameId, 5);

        vm.prank(playerZero);
        t.takeTurn(gameId, 6);

        vm.prank(playerOne);
        t.takeTurn(gameId, 7);

        vm.prank(playerZero);
        t.takeTurn(gameId, 8);

        uint256 gameBoard = t.retrieveGame(gameId);
        assertEq(isolateWinnerByte(gameBoard), 3);
    }

    function testGameOverMath() public {
        uint256 gameId = t.createNewGame(playerZero, playerOne);
        vm.prank(playerZero);
        t.takeTurn(gameId, 0);
        vm.prank(playerOne);
        t.takeTurn(gameId, 3);
        vm.prank(playerZero);
        t.takeTurn(gameId, 1);
        vm.prank(playerOne);
        t.takeTurn(gameId, 4);
        vm.prank(playerZero);
        t.takeTurn(gameId, 2);
        uint256 gameBoard = t.retrieveGame(gameId);
        assertEq(isolateWinnerByte(gameBoard), 1);
    }

    function isolateWinnerByte(uint256 gameBoard) public pure returns (uint256 winner) {
        uint256 mask = uint256(0xff << 80);
        return (gameBoard & mask) >> 80;
    }
}
