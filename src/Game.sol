// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library Game {
    using Game for uint256;

    error IllegalMove();


    function applyMove(uint256 _board, uint256 _move) internal pure returns (uint256) {
        // I think I want to just take the or, check for winner, flip the turn
        _board |= _move;

       // what is the most efficient way to flip just the bit representing whose turn it is
       uint256 mask = (_board & (0xff << 72));
        _board |= mask ^ (0x01 << 72);
       // 
        return _board;


       // might look like this 
           // your game board 
        // 0x000000000000000000000000 | 0x000000000000000000000001
        // 0x00000000000000000000000000000000000000000000ff000000000000000000
        
        // this is how you update the turn --
        // mask to isolate just the section that you want 
        // 0x0000|00|000000000000000001
        // &
        // 0x0000|ff|000000000000000000
    }

    

    
    function isLegalMove(uint256 _board, uint256 _move) internal pure returns (bool) {
        return true;
    }

}