// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "solmate/tokens/ERC721.sol";
import "solmate/auth/Owned.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

import {Game} from "src/Game.sol";

contract TicTacToe is ERC721, Owned {
    using Game for uint256;
    using Strings for uint256;
    
    uint256 currentGameId;
    mapping(uint256 => uint256) mapOfPlayerZerosAndGames;
    mapping(uint256 => address) mapOfPlayerOnes;
    string private baseURI;

    error NotYourTurn();
    error InvalidPlayer();


    constructor() ERC721("TicTacToe", "xoxo") Owned(msg.sender) {}

    function createNewGame(address _playerZero, address _playerOne) external returns(uint256) {
        uint256 gameId = currentGameId++;
        mapOfPlayerZerosAndGames[gameId] = uint256(uint160(_playerZero));
        mapOfPlayerOnes[gameId] = _playerOne;
        return gameId;
    }

    function retrieveAllGameInfo(uint256 _gameId) public view returns (uint256, address) {
        return(mapOfPlayerZerosAndGames[_gameId], mapOfPlayerOnes[_gameId]);
    }

    function retrieveGame(uint256 _gameId) public view returns (uint256) {
        return mapOfPlayerZerosAndGames[_gameId] >> 160;
    }

    function takeTurn(uint256 _gameId, uint256 _move) external {
        unchecked {
            
            (uint256 gameInfo, address playerOne) = retrieveAllGameInfo(_gameId);
            uint256 game = gameInfo >> 160;

            if (!game.isLegalMove(_move)) {
                revert Game.IllegalMove();
            }

            if (game.isGameOver()) {
                revert Game.GameOver();
            }

            address playerZero = address(uint160(gameInfo));
            uint256 turn = game.getTurn();

            if (msg.sender != playerZero && msg.sender != playerOne) {
                revert InvalidPlayer();
            }
            
            if (msg.sender == playerZero && turn == 1) {
                revert NotYourTurn();
            }
            
            if (msg.sender == playerOne && turn == 0) {
                revert NotYourTurn();
            } 


            mapOfPlayerZerosAndGames[_gameId] = (game.applyMove(_move) << 160) | uint256(uint160(playerZero));

        }
    }

    function writeGame(uint256 _gameId, uint256 _gameState) public {
        uint160 playerZero = uint160(mapOfPlayerZerosAndGames[_gameId]);
        mapOfPlayerZerosAndGames[_gameId] = (_gameState << 160) | playerZero;
    }

    function setBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        return
            (bytes(baseURI)).length == 0 ? _tokenURI(_tokenId) : string(abi.encodePacked(baseURI, _tokenId.toString()));
    }

    function _tokenURI(uint256 _tokenId) public view returns (string memory) {
        return "";
    }
}
