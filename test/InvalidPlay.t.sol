// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/TicTacToe.sol";
import {Game} from "src/Game.sol";

contract InvalidPlayTest is Test {
    TicTacToe t;
    address playerZero;
    address playerOne;

    function setUp() public {
        t = new TicTacToe();
        playerZero = 0x4675C7e5BaAFBFFbca748158bEcBA61ef3b0a263;
        playerOne = 0xFeebabE6b0418eC13b30aAdF129F5DcDd4f70CeA;
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
}
