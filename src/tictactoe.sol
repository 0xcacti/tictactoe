// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "solmate/token/ERC721.sol";
import {Game} from "src/Game.sol";

contract TicTacToe is ERC721 {
    using Game for uint256;
    uint256 currentGameId;
    mapping(uint256 => uint256) mapOfPlayerZerosAndGames;
    mapping(uint256 => address) mapOfPlayerOnes;

    function createNewGame(address _playerZero, address _playerOne) external {
        uint256 gameId = currentGameId++;
        mapOfPlayerZerosAndGames[gameId] = uint256(uint160(_playerZero));
        mapOfPlayerOnes[gameId] = _playerOne;
    }

    function retrieveGame(uint256 _gameId) public view returns (uint256) {
        return mapOfPlayerZerosAndGames[_gameId] >> 160;
    }

    function takeTurn(uint256 _gameId, uint256 _move) external {
        unchecked {
            uint256 game = retrieveGame(_gameId);
            if (!game.isLegalMove(_move)) {
                revert Game.IllegalMove();
            }
            game = game.applyMove(_move);
        }
    }

    function writeGame(uint256 _gameId, uint256 _gameState) public {
        uint160 playerZero = uint160(mapOfPlayerZerosAndGames[_gameId]);
        mapOfPlayerZerosAndGames[_gameId] = (_gameState << 160) | playerZero;
    }
}
