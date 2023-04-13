// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/TicTacToe.sol";
import "test/Utils.sol";
import {Game} from "src/Game.sol";

contract GaveOverTest is Test {
    TicTacToe game;
    Utils utils;
    address playerZero;
    address playerOne;

    function setUp() public {
        game = new TicTacToe();
        playerZero = 0x4675C7e5BaAFBFFbca748158bEcBA61ef3b0a263;
        playerOne = 0xFeebabE6b0418eC13b30aAdF129F5DcDd4f70CeA;
        utils = new Utils(game, playerZero, playerOne);
    }

    function testGameOverDraw() public {
        uint256 gameID = game.createNewGame(playerZero, playerOne);
        uint256[9] memory turns = [uint256(1), 0, 3, 2, 4, 5, 6, 7, 8];
        utils.playGame(gameID, turns);
        assertEq(utils.isolateWinnerByte(gameID), 3);
    }

    function testRowWinConditions() public {
        uint256[5][3] memory gameTurns = [[uint256(0), 3, 1, 4, 2], [uint256(3), 0, 4, 1, 5], [uint256(6), 0, 7, 1, 8]];
        for (uint256 i = 0; i < gameTurns.length; i++) {
            uint256 gameID = game.createNewGame(playerZero, playerOne);
            utils.playGame(gameID, gameTurns[i]);
            assertEq(utils.isolateWinnerByte(gameID), 1);
        }
    }

    function testColumnWinConditions() public {
        uint256[5][3] memory gameTurns = [[uint256(0), 1, 3, 4, 6], [uint256(1), 0, 4, 3, 7], [uint256(2), 0, 5, 3, 8]];
        for (uint256 i = 0; i < gameTurns.length; i++) {
            uint256 gameID = game.createNewGame(playerZero, playerOne);
            utils.playGame(gameID, gameTurns[i]);
            assertEq(utils.isolateWinnerByte(gameID), 1);
        }
    }

    function testDiagonalWinConditions() public {
        uint256[5][2] memory gameTurns = [[uint256(0), 1, 4, 3, 8], [uint256(2), 0, 4, 1, 6]];
        for (uint256 i = 0; i < gameTurns.length; i++) {
            uint256 gameID = game.createNewGame(playerZero, playerOne);
            utils.playGame(gameID, gameTurns[i]);
            assertEq(utils.isolateWinnerByte(gameID), 1);
        }
    }
}
