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
        (uint256 gameBefore, ) = t.retrieveAllGameInfo(gameId);
        console.logBytes32(bytes32(gameBefore));
        // 00 00 00 | 00 00 00 | 00 00 00
        t.takeTurn(gameId, 8);
        (uint256 gameAfter, ) = t.retrieveAllGameInfo(gameId);
        console.logBytes32(bytes32(gameAfter));
        t.takeTurn(gameId, 7);
        (uint256 gameAfter2, ) = t.retrieveAllGameInfo(gameId);
        console.logBytes32(bytes32(gameAfter2));
        t.takeTurn(gameId, 6);
        (uint256 gameAfter3, ) = t.retrieveAllGameInfo(gameId);
        console.logBytes32(bytes32(gameAfter3));

        // 0x0000010100000000000000004675c7e5baafbffbca748158becba61ef3b0a263
        // 0x0000000102000000000000004675c7e5baafbffbca748158becba61ef3b0a263
        // 0x0000010102020000000000004675c7e5baafbffbca748158becba61ef3b0a263

        
        // I want to mock check for is legal move here


    }

    function testThingy() public {
        uint256 turnPosition = 0xff << 72;
        uint256 _board = 0;
        console2.logBytes32(bytes32(_board));
        console2.logBytes32(bytes32(turnPosition));
        console2.log("");


        // take turn 
        uint256 mark = (( _board ^ turnPosition) ==  turnPosition ? 0x01 : 0x02);
        console2.logBytes32(bytes32(mark));
        uint256 _move = 8;
        _board |= (mark << (_move * 8));
        _board ^= (0x01 << 72);
        console2.logBytes32(bytes32(_board));
        console2.log("");

        // take second turn 
        mark = (( _board ^ turnPosition) ==  turnPosition ? 0x01 : 0x02);
        console2.logBytes32(bytes32(mark));
        _move = 7;
        _board |= (mark << (_move * 8));
        _board ^= (0x01 << 72);
        console2.logBytes32(bytes32(_board));
        console2.log("");



        // take third turn 
        mark = (( _board ^ turnPosition) ==  turnPosition ? 0x01 : 0x02);
        console2.logBytes32(bytes32(mark));
        _move = 6;
        _board |= (mark << (_move * 8));
        _board ^= (0x01 << 72);
        console2.logBytes32(bytes32(_board));
        console2.log("");
        uint256 xor =  0x0000000000000000000000000000000000000000000000010200000000000000 ^ 0x00000000000000000000000000000000000000000000ff000000000000000000;
        console2.logBytes32(bytes32(xor));
        // 0x00000000000000000000000000000000000000000000 01 01 00 00 00 00 00 00 00 00
        // 0x00000000000000000000000000000000000000000000 ff 00 00 00 00 00 00 00 00 00
        // ^ != 0xff so we use 2 next 
        // 
        // 0x00000000000000000000000000000000000000000000 00 01 02 00 00 00 00 00 00 00
        // ^ 
        // 0x00000000000000000000000000000000000000000000 ff 00 00 00 00 00 00 00 00 00
        // ----------------------------------------------------------------------------
        // 0x00000000000000000000000000000000000000000000 ff 01 02 00 00 00 00 00 00 00

        // 0x00000000000000000000000000000000000000000000 01 01 02 02 00 00 00 00 00 00
 
    // you have to figure out why turn isn't switching right.

        
    }



    // your game board 
        // 0x00 00 00 | 00 00 00 | 00 00 00 | 00 00 00
        //         turnByte : 0 => playerZero's turn, 1 => playerOnes turn, 2 => gameHasEnded
        //      winnerByte;



}
