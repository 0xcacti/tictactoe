// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract tictactoe {
        uint256 currentGameId;
    mapping(uint256 => uint256) mapOfPlayerZerosAndGames;
    mapping(uint256 => address) mapOfPlayerOnes;

    function createNewGame(address _playerZero, address _playerOne) external {
        uint256 gameId = currentGameId++;
        mapOfPlayerZerosAndGames[gameId] = uint256(uint160(_playerZero));
        mapOfPlayerOnes[gameId] = _playerOne;
    }

    function retrieveGame(uint256 _gameId) external view returns (uint256) {
        return mapOfPlayerZerosAndGames[_gameId] >> 160;
    }

    function writeGame(uint256 _gameId, uint256 _gameState) external {
        uint160 playerZero = uint160(mapOfPlayerZerosAndGames[_gameId]);
        mapOfPlayerZerosAndGames[_gameId] = (_gameState << 160) | playerZero;
    }
}
