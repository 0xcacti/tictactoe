// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library Game {
    using Game for uint256;

    error IllegalMove();
    error GameOver();
    uint256 constant turnPosition = 0x01 << 72;


    function applyMove(uint256 _board, uint256 _move) internal pure returns (uint256) {

        // pass in board index 
        // check move is valid 
        // check for player turn 
        // apply one or two as move depending on player turn 
        // return board 

        // I think I want to just take the or, check for winner, flip the turn
        
        uint256 mark = (( _board ^ turnPosition) ==  turnPosition ? 0x01 : 0x02);
        _board |= (mark << (_move * 8));
        _board ^= turnPosition;
        return _board;
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

    function getTurn(uint256 _board) public returns (uint256 turn) {
        uint256 mask = uint256(0xff << 72);   
        return (_board & mask) >> 72;
    } 

    function getWinner(uint256 _board) public returns (uint256 winner) {

    }

    

}