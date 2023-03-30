// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library Game {
    using Game for uint256;

    error IllegalMove();
    error GameOver();

    uint256 constant turnPosition = 0x01 << 72;
    uint256 constant gameOverPosition = 0x01 << 80;
    uint256 constant turnCountPosition = 0x01 << 88;
    uint256 constant playerOneWinsRow = 0x010101;
    uint256 constant playerTwoWinsRow = 0x020202;
    uint256 constant playerOneWinsColumn = 0x000001000001000001;
    uint256 constant playerTwoWinsColumn = 0x000002000002000002;
    uint256 constant boardRowMask = 0xFFFFFF;
    uint256 constant boardColumnMask = 0x0000FF0000FF0000FF;
    uint256 constant diagonalOneMask = 0xFF000000FF000000FF;
    uint256 constant diagonalTwoMask = 0x0000FF00FF00FF0000;
    uint256 constant playerOneWinsDiagOne = 0x010000000100000001;
    uint256 constant playerTwoWinsDiagOne = 0x020000000200000002;
    uint256 constant playerOneWinsDiagTwo = 0x000001000100010000;
    uint256 constant playerTwoWinsDiagTwo = 0x000002000200020000;

    // 0x0000000000000000000000000000000000000000000100000000 02 02 00 01 01 01
    function applyMove(uint256 _board, uint256 _move) internal pure returns (uint256) {
        uint256 mark = getTurn(_board) == 0x00 ? 0x01 : 0x02;
        _board |= (mark << (_move * 8));
        _board += turnCountPosition;

        if ((_board >> 88) > 4) {
            uint256 winner = _board.checkForWinner();
            if (winner != 0) {
                _board |= winner << 80; // set winner in winner position
            }
        }

        _board ^= turnPosition; // flip turn

        return _board;
    }

    function isGameOver(uint256 _board) internal pure returns (bool) {
        uint256 mask = uint256(0xff << 80);
        // winnerByte : 0 => No Winner, 1 => playerZero, 2 => playerOne, 3 => tie game
        return ((_board & mask) != 0);
    }

    function checkForWinner(uint256 _board) internal pure returns (uint256) {
        uint256 winner = 0;

        if (_board & 0xFF << 88 == 0x09 << 88) {
            winner = 0x03;
            return winner;
        }

        uint256 player = getTurn(_board);
        uint256 mark = (player == 0) ? 0x01 : 0x02;

        for (uint256 i = 0; i < 3; i++) {
            uint256 row = (_board & boardRowMask) << (i * 8 * 3);
            if ((row >> (i * 8 * 3)) == playerOneWinsRow || (row >> (i * 8 * 3)) == playerTwoWinsRow) {
                winner = mark;
            }
        }

        // 0 1 2
        // 3 4 5
        // 6 7 8

        // 0x000000
        // 00 00 00  00 00 00  00 00 00
        // col1 ==  0x0000FF0000FF0000FF
        // check columns

        // diag 1 == 0x01 00 00 00 01 00 00 00 01
        // diag 2 == 0x00 00 01 00 01 00 01 00 00
        for (uint256 i = 0; i < 3; i++) {
            uint256 col = (_board & boardColumnMask) << (i * 8);
            if ((col) >> (i * 8) == playerOneWinsColumn || (col) >> (i * 8) == playerTwoWinsColumn) {
                winner = mark;
            }
        }

        // check diagonal 1 - generated
        // uint256 diag1 = 0;
        // uint256 diag2 = 0;
        // for (uint256 i = 0; i < 3; i++) {
        //     diag1 |= (_board & (0xff << (i * 8 * 4))) >> (i * 8 * 4);
        //     diag2 |= (_board & (0xff << (i * 8 * 2 + 24))) >> (i * 8 * 2 + 24);
        // }
        uint256 diag1 = _board & diagonalOneMask;
        uint256 diag2 = _board & diagonalTwoMask;
        if (diag1 == playerOneWinsDiagOne || diag1 == playerTwoWinsDiagOne) {
            winner = mark;
        }
        if (diag2 == playerOneWinsDiagTwo || diag1 == playerTwoWinsDiagTwo) {
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

}
