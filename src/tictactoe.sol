// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "solmate/tokens/ERC721.sol";
import "solmate/auth/Owned.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import {TicTacToeArt} from "src/TicTacToeArt.sol";

import {Game} from "src/Game.sol";

contract TicTacToe is ERC721, Owned {
    using Game for uint256;
    using Strings for uint256;

    uint96 gameId;

    uint256 mintPrice = 0.02 ether;

    mapping(uint256 => uint256) mapOfPlayerZerosAndGames;
    mapping(uint256 => address) mapOfPlayerOnes;
    string private baseURI;

    error NotYourTurn();
    error InvalidPlayer();
    error InvalidMinter();
    error IncorrectPayment();
    error GameNotOver();

    constructor() ERC721("TicTacToe", "xoxo") Owned(msg.sender) {}

    function createNewGame(address _playerZero, address _playerOne) external returns (uint256) {
        uint256 currentGameId = gameId;
        gameId += 2;
        mapOfPlayerZerosAndGames[currentGameId] = uint256(uint160(_playerZero));
        mapOfPlayerOnes[currentGameId] = _playerOne;
        return currentGameId;
    }

    function retrieveAllGameInfo(uint256 _gameId) public view returns (uint256, address, address) {
        uint256 gameInfo = mapOfPlayerZerosAndGames[_gameId];
        return (gameInfo >> 160, address(uint160(gameInfo)), mapOfPlayerOnes[_gameId]);
    }

    function retrieveGame(uint256 _gameId) public view returns (uint256) {
        return mapOfPlayerZerosAndGames[_gameId] >> 160;
    }

    function takeTurn(uint256 _gameId, uint256 _move) external {
        unchecked {
            (uint256 game, address playerZero, address playerOne) = retrieveAllGameInfo(_gameId);

            if (!game.isLegalMove(_move)) {
                revert Game.IllegalMove();
            }

            if (game.getWinner() != 0) {
                revert Game.GameOver();
            }

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

    function mintGame(uint256 gameId) external payable {
        // pass a gameId
        // mint two NFTs that can be looked up with their tokenID
        // one to playerZero
        // one to playerOne
        // gameId is a bit packed uint256, with the first 96 bits being the gameId + the playerNumber and the last 160 bits being the playerAddress

        // mint two NFTs
        // one to playerZero
        // one to playerOne
        // this can be maybe gameID bit packed with player Address

        (uint256 game, address playerZero, address playerOne) = retrieveAllGameInfo(gameId);

        if (msg.value != mintPrice) {
            revert IncorrectPayment();
        }

        if (msg.sender != playerZero || msg.sender != playerOne) {
            revert InvalidMinter();
        }

        if (game.getWinner() == 0) {
            revert GameNotOver();
        }

        uint256 playerZeroTokenId = (gameId << 160) | uint256(uint160(playerZero));
        uint256 playerOneTokenId = ((gameId + 1) << 160) | uint256(uint160(playerOne));
        _mint(playerZero, playerZeroTokenId);
        _mint(playerOne, playerOneTokenId);
    }

    function setBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        return
            (bytes(baseURI)).length == 0 ? _tokenURI(_tokenId) : string(abi.encodePacked(baseURI, _tokenId.toString()));
    }

    function _tokenURI(uint256 _tokenId) public view returns (string memory) {
        uint256 gameIdComponent = _tokenId >> 160;
        uint256 _gameId = (gameIdComponent % 2 == 0) ? gameIdComponent : gameIdComponent - 1;
        (uint256 game, address playerZero, address playerOne) = retrieveAllGameInfo(_gameId);
        return TicTacToeArt.getMetadata(_gameId, _tokenId, game, playerZero, playerOne);
    }
}
