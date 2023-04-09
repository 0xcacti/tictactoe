// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/TicTacToe.sol";
import {Game} from "src/Game.sol";

contract GameBehaviorTest is Test {
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
        (uint256 game, address _playerZero, address _playerOne) = t.retrieveAllGameInfo(gameId);
        assertEq(game, 0);
        assertEq(_playerZero, playerZero);
        assertEq(_playerOne, playerOne);
    }

    function testSwitchTurnSucceeds() public {
        uint256 playerZerosTurn = 0;
        uint256 playerOnesTurn = 1;

        uint256 gameId = t.createNewGame(playerZero, playerOne);
        uint256 gameBoard = t.retrieveGame(gameId);

        vm.prank(playerZero);
        t.takeTurn(gameId, 8);
        gameBoard = t.retrieveGame(gameId);
        assertEq(isolateTurnByte(gameBoard), playerOnesTurn);

        vm.prank(playerOne);
        t.takeTurn(gameId, 7);
        gameBoard = t.retrieveGame(gameId);
        assertEq(isolateTurnByte(gameBoard), playerZerosTurn);

        vm.prank(playerZero);
        t.takeTurn(gameId, 6);
        gameBoard = t.retrieveGame(gameId);
        assertEq(isolateTurnByte(gameBoard), playerOnesTurn);
    }

    function isolateTurnByte(uint256 gameBoard) public pure returns (uint256 turn) {
        uint256 mask = uint256(0xff << 72);
        return (gameBoard & mask) >> 72;
    }
}
