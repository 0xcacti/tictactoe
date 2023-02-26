// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library Game {
    using Game for uint256;

    error IllegalMove();


    function applyMove(uint256 _board, uint256 _move) internal pure returns (uint256) {}

    
    function isLegalMove(uint256 _board, uint256 _move) internal pure returns (bool) {
        return true;
    }

    function isValid(uint256 _board, uint256 _toIndex) internal pure returns (bool) {

    }


    function getAdjustedIndex(uint256 _index) internal pure returns (uint256) {

    }


}