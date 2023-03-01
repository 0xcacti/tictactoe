// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library Game {
    using Game for uint256;

    error IllegalMove();
    uint256 constant turnPosition = 0xff << 72;


    function applyMove(uint256 _board, uint256 _move) internal pure returns (uint256) {

        // pass in board index
        // check move is valid 
        // check for player turn 
        // apply one or two as move depending on player turn 
        // return board 

        // I think I want to just take the or, check for winner, flip the turn
        
        uint256 mark = (( _board ^ turnPosition) ==  turnPosition ? 0x01 : 0x02);

        // need to programatically turn mark into the right location, if it's 0, then were fine 
        // if it's 0, 
        // if it's 1 => 8 bit shift 
        // if it's 2 => 4
        // if it's 3 => 
        // 0x000000
        // 0x0000020000
        _board |= (mark << (_move * 8));
        _board ^= (0x01 << 72);
        return _board;
    }

    

    
    function isLegalMove(uint256 _board, uint256 _move) internal pure returns (bool) {
        return true;
    }

}