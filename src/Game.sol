// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @title Game logic library for playing tictactoe
/// @author 0xcacti
/// @notice Below is a library that handles all logic around the actual game play of tictactoe
/// @dev The game's are designed to fit into a single uint256.  All game information is stored 
/// in the first 96 bits of the uint256.  The first byte to the right of the 0x is the turn count.
/// Values range between (0-9).  The next byte to the right is the win status of the board.  
/// Values range between 0-3.  0 represents a game in progress, 1 represents player zero wins, 
/// 2 represents player one wins, and 3 represents a draw.  The next byte to the right 
/// flips between 0 and 1 to denote player turn.  The subsequent 9 bytes to the right represent 
/// the actual game board.  Values range between 0-2.  0 represents an empty space, 1 represents
/// a player zero move, and 2 represents a player one move.  The board is represented from left 
/// to right, top to bottom e.g. 
/// 0 1 2 
/// 3 4 5
/// 6 7 8 
/// All trailing bytes are used to store playerZero's address. This is done to save gas on 
/// storing players addresses. 

library Game {
    using Game for uint256;

    /*//////////////////////////////////////////////////////////////
                               CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice location of turn tracking byte
    uint256 constant TURN_POSITION = 0x01 << 72;

    /// @notice location of turn count tracking byte
    uint256 constant TURN_COUNT_POSITION = 0x01 << 88;

    /// @notice constant representing player zero win condition in row
    uint256 constant PLAYER_ZERO_WINS_ROW = 0x010101;

    /// @notice constant representing player one win condition in row
    uint256 constant PLAYER_ONE_WINS_ROW = 0x020202;

    /// @notice constant representing player zero win condition in column
    uint256 constant PLAYER_ZERO_WINS_COLUMN = 0x000001000001000001;

    /// @notice constant representing player one win condition in column
    uint256 constant PLAYER_ONE_WINS_COLUMN = 0x000002000002000002;

    /// @notice constant representing player zero win condition in diagonal top left to bottom right
    uint256 constant PLAYER_ZERO_WINS_DIAG_ZERO = 0x010000000100000001;

    /// @notice constant representing player one win condition in diagonal top left to bottom right
    uint256 constant PLAYER_ONE_WINS_DIAG_ZERO = 0x020000000200000002;

    /// @notice constant representing player zero win condition in diagonal top right to bottom left
    uint256 constant PLAYER_ZERO_WINS_DIAG_ONE = 0x000001000100010000;

    /// @notice constant representing player one win condition in diagonal top right to bottom left
    uint256 constant PLAYER_ONE_WINS_DIAG_ONE = 0x000002000200020000;

    /// @notice constant mask to fetch a row from the board
    uint256 constant BOARD_ROW_MASK = 0xffffff;

    /// @notice constant mask to fetch a column from the board
    uint256 constant BOARD_COLUMN_MASK = 0x0000ff0000ff0000ff;

    /// @notice constant mask to fetch a diagonal top left to bottom right from the board
    uint256 constant DIAGONAL_ZERO_MASK = 0xff000000ff000000ff;

    /// @notice constant mask to fetch a diagonal top right to bottom left from the board
    uint256 constant DIAGONAL_ONE_MASK = 0x0000ff00ff00ff0000;

    /*//////////////////////////////////////////////////////////////
                               ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice error on illegal move 
    error IllegalMove();

    /// @notice error on illegal actions after game is over
    error GameOver();

    /// @notice error on illegal actions before game is over
    error GameNotOver();


    /*//////////////////////////////////////////////////////////////
                               CORE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice takes a legal move and returns the new board state 
    /// @dev the move is an int between 0 and 8 inclusive representing the position on the board 
    /// where 0 is the top left corner and 8 is the bottom right corner
    /// @param _board the current board state
    /// @param _move the move to be made
    /// @return the new board state
    function applyMove(uint256 _board, uint256 _move) internal pure returns (uint256) {

        // get x or o
        uint256 mark = getTurn(_board) == 0x00 ? 0x01 : 0x02;

        // apply move
        _board |= (mark << (_move * 8));

        // increase turn count
        _board += TURN_COUNT_POSITION;

        // if turn count is large enough to have a winner, check for winner
        if (getTurnCount(_board) > 4) {
            uint256 winner = _board.checkForWinner();
            _board |= winner << 80;
        }
        
        // flip the turn bit
        _board ^= TURN_POSITION;

        // return the board
        return _board;
    }

    /// @notice checks if the game is over
    /// @dev this function is only called once there are at least 5 moves on the board
    /// this is the earliest possible number of moves for a win to occur
    /// @param _board the current board state
    /// @return 0 if the game is not over, 1 if player zero has won, 2 if player one has won, 3 if the game is a draw
    function checkForWinner(uint256 _board) internal pure returns (uint256) {
        // initialize winner variable
        uint256 winner = 0;

        // get x or o of last move - the winner will be the last player to take a turn
        uint256 mark = (getTurn(_board) == 0) ? 0x01 : 0x02;

        // check each row for a win by masking the row and checking if it is equal to the win condition for that player
        for (uint256 i = 0; i < 3; i++) {
            uint256 row = (_board >> (i * 8 * 3)) & BOARD_ROW_MASK;
            if (row == PLAYER_ZERO_WINS_ROW || row == PLAYER_ONE_WINS_ROW) {
                winner = mark;
            }
        }

        // check each column for a win by masking the column and checking if it is equal to the win condition for that player
        for (uint256 i = 0; i < 3; i++) {
            uint256 col = (_board >> (i * 8)) & BOARD_COLUMN_MASK;
            if (col == PLAYER_ZERO_WINS_COLUMN || col == PLAYER_ONE_WINS_COLUMN) {
                winner = mark;
            }
        }
        
        // check each diagonal for a win by masking the diagonal and checking if it is equal to the win condition for that player
        uint256 diag0 = _board & DIAGONAL_ZERO_MASK;
        uint256 diag1 = _board & DIAGONAL_ONE_MASK;
        if (diag0 == PLAYER_ZERO_WINS_DIAG_ZERO || diag0 == PLAYER_ONE_WINS_DIAG_ZERO) {
            winner = mark;
        }
        if (diag1 == PLAYER_ZERO_WINS_DIAG_ONE || diag1 == PLAYER_ONE_WINS_DIAG_ONE) {
            winner = mark;
        }

        // check for draw by seeing if the turn count is 9 and no other winner has been found
        if ((_board & (0xff << 88) == 0x09 << 88) && (winner == 0)) { 
            winner = 0x03;
            return winner;
        }

        // return winner
        return winner;
    }

    /// @notice checks if a move is legal
    /// @dev a move is legal if it is in bounds and the spot on the board is not occupied
    /// @param _board the current board state
    /// @param _move the move to be made
    /// @return true if the move is legal, false otherwise
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

    /*//////////////////////////////////////////////////////////////
                               UTILS
    //////////////////////////////////////////////////////////////*/

    /// @notice returns the current turn
    /// @dev 0 represents player zero, 1 represents player one, turn is stored 
    // in 10th byte, to the left of the 9 bytes representing the board
    /// @param _board the current board state
    /// @return turn the current turn
    function getTurn(uint256 _board) internal pure returns (uint256 turn) {
        uint256 mask = uint256(0xff << 72);
        return (_board & mask) >> 72;
    }

    /// @notice returns the winner of the game
    /// @dev 1 represents player zero, 2 represents player one, 3 represents a draw
    /// the winner is stored in the 11th byte, to the left of the 10th byte representing the turn
    /// @param _board the current board state
    /// @return winner the winner of the game
    function getWinner(uint256 _board) internal pure returns (uint256 winner) {
        uint256 mask = uint256(0xff << 80);
        return (_board & mask) >> 80;
    }

    /// @notice returns the number of turns that have been played
    /// @dev the turn count is stored in the 12th byte, to the left of the 11th byte representing the winner
    /// @param _board the current board state
    /// @return turnCount the number of turns that have been played
    function getTurnCount(uint256 _board) internal pure returns (uint256 turnCount) {
        uint256 mask = uint256(0xff << 88);
        return (_board & mask) >> 88;
    }
}
