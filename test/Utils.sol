// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "src/TicTacToe.sol";
import "forge-std/Test.sol";
import {Game} from "src/Game.sol";

contract Utils is Test {
    TicTacToe immutable game;
    address immutable playerZero;
    address immutable playerOne;
    address currentPlayer;

    constructor(TicTacToe _game, address _playerZero, address _playerOne) {
        game = _game;
        playerZero = _playerZero;
        playerOne = _playerOne;
    }

    function playGame(uint256 gameID, uint256[1] memory turns) public {
        for (uint256 i = 0; i < turns.length; i++) {
            currentPlayer = (isolateTurnByte(gameID) == 0) ? playerZero : playerOne;
            vm.prank(currentPlayer);
            game.takeTurn(gameID, turns[i]);
        }
    }

    function playGame(uint256 gameID, uint256[2] memory turns) public {
        for (uint256 i = 0; i < turns.length; i++) {
            currentPlayer = (isolateTurnByte(gameID) == 0) ? playerZero : playerOne;
            vm.prank(currentPlayer);
            game.takeTurn(gameID, turns[i]);
        }
    }

    function playGame(uint256 gameID, uint256[3] memory turns) public {
        for (uint256 i = 0; i < turns.length; i++) {
            currentPlayer = (isolateTurnByte(gameID) == 0) ? playerZero : playerOne;
            vm.prank(currentPlayer);
            game.takeTurn(gameID, turns[i]);
        }
    }

    function playGame(uint256 gameID, uint256[4] memory turns) public {
        for (uint256 i = 0; i < turns.length; i++) {
            currentPlayer = (isolateTurnByte(gameID) == 0) ? playerZero : playerOne;
            vm.prank(currentPlayer);
            game.takeTurn(gameID, turns[i]);
        }
    }

    function playGame(uint256 gameID, uint256[5] memory turns) public {
        for (uint256 i = 0; i < turns.length; i++) {
            currentPlayer = (isolateTurnByte(gameID) == 0) ? playerZero : playerOne;
            vm.prank(currentPlayer);
            game.takeTurn(gameID, turns[i]);
        }
    }

    function playGame(uint256 gameID, uint256[6] memory turns) public {
        for (uint256 i = 0; i < turns.length; i++) {
            currentPlayer = (isolateTurnByte(gameID) == 0) ? playerZero : playerOne;
            vm.prank(currentPlayer);
            game.takeTurn(gameID, turns[i]);
        }
    }

    function playGame(uint256 gameID, uint256[7] memory turns) public {
        for (uint256 i = 0; i < turns.length; i++) {
            currentPlayer = (isolateTurnByte(gameID) == 0) ? playerZero : playerOne;
            vm.prank(currentPlayer);
            game.takeTurn(gameID, turns[i]);
        }
    }

    function playGame(uint256 gameID, uint256[8] memory turns) public {
        for (uint256 i = 0; i < turns.length; i++) {
            currentPlayer = (isolateTurnByte(gameID) == 0) ? playerZero : playerOne;
            vm.prank(currentPlayer);
            game.takeTurn(gameID, turns[i]);
        }
    }

    function playGame(uint256 gameID, uint256[9] memory turns) public {
        for (uint256 i = 0; i < turns.length; i++) {
            currentPlayer = (isolateTurnByte(gameID) == 0) ? playerZero : playerOne;
            vm.prank(currentPlayer);
            game.takeTurn(gameID, turns[i]);
        }
    }

    function isolateWinnerByte(uint256 gameID) public view returns (uint256 winner) {
        uint256 gameBoard = game.retrieveGame(gameID);
        uint256 mask = uint256(0xff << 80);
        return (gameBoard & mask) >> 80;
    }

    function isolateTurnByte(uint256 gameID) public view returns (uint256 turn) {
        uint256 gameBoard = game.retrieveGame(gameID);
        uint256 mask = uint256(0xff << 72);

        return (gameBoard & mask) >> 72;
    }
}
