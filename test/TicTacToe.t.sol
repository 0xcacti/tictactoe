// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


import "forge-std/Test.sol";
import "src/TicTacToe.sol";

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

    function testSwitchTurnSucceeds() public {
        console2.logBytes32(bytes32((uint256(0xff << 72))));
        uint256 gameId = t.createNewGame(playerZero, playerOne);
        uint256 gameBefore = t.retrieveGame(gameId);
        console.logBytes32(bytes32(gameBefore));


        t.takeTurn(gameId, 1);
        uint256 gameAfter = t.retrieveGame(gameId);
        console.logBytes32(bytes32(gameAfter));
        

        // I want to mock check for is legal move here


    }

    function testThingy() public {
        uint256 _board = 0;
        console2.logBytes32(bytes32(_board));
        uint256 _mask = (0xff << 72);
        console2.logBytes32(bytes32(_mask));
        uint256 maskedBoard = _board & _mask;
        console2.logBytes32(bytes32(maskedBoard));
        uint256 _turnSwitcher = (0x01 << 72);
        console2.logBytes32(bytes32(_turnSwitcher));
        _board |= maskedBoard ^ _turnSwitcher;
        console2.logBytes32(bytes32(_board));
        
    }



    // your game board 
        // 0x00 00 00 | 00 00 00 | 00 00 00 | 00 00 00
        //         turnByte : 0 => playerZero's turn, 1 => playerOnes turn, 2 => gameHasEnded
        //      winnerByte;



}
