// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library Game {
    using Game for uint256;

    error IllegalMove();
    error GameOver();
    error GameNotOver();

    uint256 constant turnPosition = 0x01 << 72;
    uint256 constant turnCountPosition = 0x01 << 88;

    uint256 constant playerOneWinsRow = 0x010101;
    uint256 constant playerTwoWinsRow = 0x020202;
    uint256 constant playerOneWinsColumn = 0x000001000001000001;
    uint256 constant playerTwoWinsColumn = 0x000002000002000002;
    uint256 constant playerOneWinsDiagZero = 0x010000000100000001;
    uint256 constant playerTwoWinsDiagZero = 0x020000000200000002;
    uint256 constant playerOneWinsDiagOne = 0x000001000100010000;
    uint256 constant playerTwoWinsDiagOne = 0x000002000200020000;

    uint256 constant boardRowMask = 0xffffff;
    uint256 constant boardColumnMask = 0x0000ff0000ff0000ff;
    uint256 constant diagonalZeroMask = 0xff000000ff000000ff;
    uint256 constant diagonalOneMask = 0x0000ff00ff00ff0000;

    function applyMove(uint256 _board, uint256 _move) internal pure returns (uint256) {
        uint256 mark = getTurn(_board) == 0x00 ? 0x01 : 0x02;
        _board |= (mark << (_move * 8));
        _board += turnCountPosition;

        if (getTurnCount(_board) > 4) {
            uint256 winner = _board.checkForWinner();
            _board |= winner << 80;
        }

        _board ^= turnPosition;

        return _board;
    }

    function checkForWinner(uint256 _board) internal pure returns (uint256) {
        uint256 winner = 0;

        if (_board & (0xff << 88) == 0x09 << 88) {
            winner = 0x03;
            return winner;
        }

        uint256 mark = (getTurn(_board) == 0) ? 0x01 : 0x02;

        for (uint256 i = 0; i < 3; i++) {
            uint256 row = (_board >> (i * 8 * 3)) & boardRowMask;
            if (row == playerOneWinsRow || row == playerTwoWinsRow) {
                winner = mark;
            }
        }

        for (uint256 i = 0; i < 3; i++) {
            uint256 col = (_board >> (i * 8)) & boardColumnMask;
            if (col == playerOneWinsColumn || col == playerTwoWinsColumn) {
                winner = mark;
            }
        }

        uint256 diag0 = _board & diagonalZeroMask;
        uint256 diag1 = _board & diagonalOneMask;
        if (diag0 == playerOneWinsDiagZero || diag0 == playerTwoWinsDiagZero) {
            winner = mark;
        }
        if (diag1 == playerOneWinsDiagOne || diag1 == playerTwoWinsDiagOne) {
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

    function getWinner(uint256 _board) internal pure returns (uint256 winner) {
        uint256 mask = uint256(0xff << 80);
        return (_board & mask) >> 80;
    }

    function getTurnCount(uint256 _board) internal pure returns (uint256 turnCount) {
        uint256 mask = uint256(0xff << 88);
        return (_board & mask) >> 88;
    }
}
