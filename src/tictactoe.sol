// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {Owned} from "solmate/auth/Owned.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {TicTacToeArt} from "src/TicTacToeArt.sol";
import {Game} from "src/Game.sol";

/// @title TicTacToe
/// @author 0xcacti
/// @notice Below is the contract for handling the state of the tictactoe games and minting the tokens.

contract TicTacToe is ERC721, Owned {
    using Game for uint256;
    using Strings for uint256;

    /*//////////////////////////////////////////////////////////////
                               CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice The owner address.
    address constant OWNER_ADDRESS = 0xB95777719Ae59Ea47A99e744AfA59CdcF1c410a1;

    // @notice Mint price.
    uint256 constant MINT_PRICE = 0.005 ether;

    /*//////////////////////////////////////////////////////////////
                               STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @notice The current Game ID.
    uint256 gameID;

    /// @notice The baseURI for the tokens - for domain resolution.
    string private baseURI;

    /// @notice Mapping of tokenIDs to their minted status.
    mapping(uint256 => bool) minted;

    /// @notice Mapping of gameIDs to their bitpacked player zero address and gameboard.
    mapping(uint256 => uint256) mapOfPlayerZerosAndGames;

    /// @notice Mapping of gameIDs to their player one address.
    mapping(uint256 => address) mapOfPlayerOnes;

    /*//////////////////////////////////////////////////////////////
                               ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Error on moving out of turn.
    error NotYourTurn();

    /// @notice Error on invalid player.
    error InvalidPlayer();

    /// @notice Error on invalid payment for mint.
    error IncorrectPayment();

    /// @notice Error on illegal actions before game is over.
    error GameNotOver();

    /// @notice Error on token not minted.
    error TokenNotMinted();

    /// @notice Error on token already minted.
    error TokenAlreadyMinted();

    /*//////////////////////////////////////////////////////////////
                        CONSTRUCTOR AND WITHDRAW 
    //////////////////////////////////////////////////////////////*/

    /// @notice Deploy the contract and set the owner.
    constructor() ERC721("TicTacToe", "XOXO") Owned(OWNER_ADDRESS) {}

    /// @notice Withdraw contract funds to the contract owner.
    function withdraw() external onlyOwner {
        (bool success,) = payable(owner).call{value: address(this).balance}("");
        require(success);
    }

    /*//////////////////////////////////////////////////////////////
                                GAMEPLAY
    //////////////////////////////////////////////////////////////*/

    /// @notice Create new game for two specified player addresses.
    /// @dev GameID iterates by two to handle tokenIDs for minting later.
    /// @param _playerZero The address of the first player.
    /// @param _playerOne The address of the second player.
    /// @return The gameID for the created game.
    function createNewGame(address _playerZero, address _playerOne) external returns (uint256) {
        uint256 currentgameID = gameID;
        gameID += 2;
        mapOfPlayerZerosAndGames[currentgameID] = uint256(uint160(_playerZero));
        mapOfPlayerOnes[currentgameID] = _playerOne;
        return currentgameID;
    }

    /// @notice Retrieve all game info for a given gameID.
    /// @dev The game is bitpacked with the gameboard in the first 96 bits
    /// and playerZero in last 160 bits of the game storage slot.
    /// @param _gameID The gameID for which to retrieve info.
    /// @return The gameID, playerZero address, and playerOne address.
    function retrieveAllGameInfo(uint256 _gameID) public view returns (uint256, address, address) {
        uint256 gameInfo = mapOfPlayerZerosAndGames[_gameID];
        return (gameInfo >> 160, address(uint160(gameInfo)), mapOfPlayerOnes[_gameID]);
    }

    /// @notice Retrieve the game board for a given gameID.
    /// @param _gameID The gameID for which to retrieve game info.
    /// @return The current game board.
    function retrieveGame(uint256 _gameID) public view returns (uint256) {
        return mapOfPlayerZerosAndGames[_gameID] >> 160;
    }

    /// @notice Take turn in tictactoe game.
    /// @param _gameID The gameID for which to take a turn.
    /// @param _move The move to take in the game moves are 0-8 indexing a tictactoe board left to right, top to bottom
    /// 0 1 2
    /// 3 4 5
    /// 6 7 8
    function takeTurn(uint256 _gameID, uint256 _move) external {
        unchecked {
            (uint256 game, address playerZero, address playerOne) = retrieveAllGameInfo(_gameID);

            if (!game.isLegalMove(_move)) {
                revert Game.IllegalMove();
            }

            if (game.getWinner() != 0) {
                revert Game.GameOver();
            }

            if (msg.sender != playerZero && msg.sender != playerOne) {
                revert InvalidPlayer();
            }

            uint256 turn = game.getTurn();


            if (msg.sender == playerZero && turn == 1) {
                revert NotYourTurn();
            }

            if (msg.sender == playerOne && turn == 0) {
                revert NotYourTurn();
            }

            mapOfPlayerZerosAndGames[_gameID] = (game.applyMove(_move) << 160) | uint256(uint160(playerZero));
        }
    }

    /*//////////////////////////////////////////////////////////////
                               MINTING
    //////////////////////////////////////////////////////////////*/

    /// @notice Mint an NFT for a given gameID and player number.
    /// @dev the playerNumber is 0 for playerZero and 1 for playerOne
    /// @param _gameID the gameID for which to mint an NFT
    /// @param playerNumber the player number for which to mint an NFT
    function mint(uint256 _gameID, uint256 playerNumber) external payable {
        if (playerNumber > 1) {
            revert InvalidPlayer();
        }

        if (msg.value != MINT_PRICE) {
            revert IncorrectPayment();
        }

        (uint256 game, address playerZero, address playerOne) = retrieveAllGameInfo(_gameID);

        if (game.getWinner() == 0) {
            revert GameNotOver();
        }

        uint256 tokenID = (_gameID << 160) | uint256(uint160(playerNumber == 0 ? playerZero : playerOne));
        if (minted[tokenID]) {
            revert TokenAlreadyMinted();
        }
        minted[tokenID] = true;
        _safeMint(playerNumber == 0 ? playerZero : playerOne, tokenID);
    }

    /// @notice mint an NFT for both players in a given gameID
    /// @param _gameID the gameID for which to mint NFTs
    function mintForBothPlayers(uint256 _gameID) external payable {
        (uint256 game, address playerZero, address playerOne) = retrieveAllGameInfo(_gameID);

        if (msg.value != 2 * MINT_PRICE) {
            revert IncorrectPayment();
        }

        if (game.getWinner() == 0) {
            revert GameNotOver();
        }

        uint256 playerZerotokenID = (_gameID << 160) | uint256(uint160(playerZero));
        uint256 playerOnetokenID = ((_gameID + 1) << 160) | uint256(uint160(playerOne));

        minted[playerZerotokenID] = true;
        minted[playerOnetokenID] = true;
        _safeMint(playerZero, playerZerotokenID);
        _safeMint(playerOne, playerOnetokenID);
    }

    /*//////////////////////////////////////////////////////////////
                               METADATA
    //////////////////////////////////////////////////////////////*/

    /// @notice set the baseURI for the contract
    /// @param _baseURI the baseURI to set
    function setBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    /// @notice get the baseURI for the contract
    /// @dev return metadata if baseURI is not previously set
    /// @param _tokenID the tokenID for which to retrieve metadata
    /// @return the tokenURI for the contract
    function tokenURI(uint256 _tokenID) public view virtual override returns (string memory) {
        if (_ownerOf[_tokenID] == address(0)) {
            revert TokenNotMinted();
        }
        return
            (bytes(baseURI)).length == 0 ? _tokenURI(_tokenID) : string(abi.encodePacked(baseURI, _tokenID.toString()));
    }

    /// @notice get the underlying tokenURI (metadata) for a given tokenID
    /// @param _tokenID the tokenID for which to retrieve metadata
    /// @return the tokenURI for the contract
    function _tokenURI(uint256 _tokenID) public view returns (string memory) {
        if (_ownerOf[_tokenID] == address(0)) {
            revert TokenNotMinted();
        }
        uint256 gameIDComponent = _tokenID >> 160;
        uint256 _gameID = (gameIDComponent % 2 == 0) ? gameIDComponent : gameIDComponent - 1;
        (uint256 game, address playerZero, address playerOne) = retrieveAllGameInfo(_gameID);
        return TicTacToeArt.getMetadata(_gameID, _tokenID, game, playerZero, playerOne);
    }
}
