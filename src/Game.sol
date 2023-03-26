// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library Game {
    using Game for uint256;

    error IllegalMove();
    error GameOver();
    uint256 constant turnPosition     = 0x01 << 72;
    uint256 constant gameOverPosition = 0x01 << 80;
    uint256 constant playerOneWins    = 0x010101;
    uint256 constant playerTwoWins    = 0x020202;
    uint256 constant boardMask        = 0xFFFFFF;


    function applyMove(uint256 _board, uint256 _move) internal pure returns (uint256) {

        // pass in board index
        // check move is valid
        // check for player turn
        // apply one or two as move depending on player turn
        // return board

        // I think I want to just take the or, check for winner, flip the turn

        uint256 mark = (( _board ^ turnPosition) ==  turnPosition ? 0x01 : 0x02);
        _board |= (mark << (_move * 8));
        // flip turn

        uint256 winner = _board.checkForWinner();
        if (winner != 0) {
            _board |= winner << 80; // set winner in winner position
        } else {
             _board ^= turnPosition; // flip turn
        }
        return _board;
    }

    function isGameOver(uint256 _board ) internal pure returns (bool) {
        uint256 mask = uint256(0xff << 80);
        // winnerByte : 0 => No Winner, 1 => playerZero, 2 => playerOne, 3 => tie game
        return ((_board & mask) != 0);
    }

    function checkForWinner(uint256 _board) internal pure returns (uint256) {
    
        // check for winner
        // if winner, set winner byte
        // if tie, set tie byte
        // if no winner, do nothing


        // set winner var, if there is a winner this will not be zero
        uint256 winner = 0;

        //         turnByte : 0 => playerZero's turn, 1 => playerOnes turn 
        // player one marks 0x01, player two marks 0x02

        // get the current players turn, if there is a winner, it will be the player who just went
        uint256 player = getTurn(_board);
        uint256 mark = ( player == 0 ) ? 0x01 : 0x02;


        // check for winner
        // check rows

        // check rows 

        for (uint256 i = 0; i < 3; i++) {
            uint256 row = (_board & boardMask) >> (i * 8 * 3);     
            if (row == playerOneWins || row == playerTwoWins) {
                winner = mark;
            }       
        }

        // check columns
        for (uint256 i = 0; i < 3; i++) {
            uint256 col = (_board & boardMask) >> (i * 8);

        }

        // check diagonals
        uint256 diag1 = 0;
        uint256 diag2 = 0;
        for (uint256 i = 0; i < 3; i++) {
            diag1 |= (_board & (player << ((i * 3 + i) * 8)));
            diag2 |= (_board & (player << ((i * 3 + (2 - i)) * 8)));
        }
        if (diag1 == (player << (0 * 8))) {
            winner = mark;
        }
        if (diag2 == (player << (2 * 8))) {
            winner = mark;
        }

        return winner;

}


    function isLegalMove(uint256 _board, uint256 _move) internal pure returns (bool) {

        // checks that the intended move is in bounds
        if (_move > 8) {
            return false;
        }
        // checks that spot on the board is not occupied
                uint256 mask = (0xff << (_move * 8));
        if ((_board & mask) != 0) {
            return false;
        }

        return true;
    }

    function getTurn(uint256 _board) internal pure returns (uint256 turn) {
        uint256 mask = uint256(0xff << 72);
        return (_board & mask) >> 72;
    }

    // function getWinner(uint256 _board) public returns (uint256 winner) {

    // }



}