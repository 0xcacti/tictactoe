// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/TicTacToe.sol";
import "test/Utils.sol";
import {Game} from "src/Game.sol";
import {IColormapRegistry} from "src/interfaces/IColormapRegistry.sol";

contract MintTest is Test {
    TicTacToe game;
    address playerZero;
    address playerOne;
    Utils utils;

    function setUp() public {
        game = new TicTacToe();
        playerZero = 0x4675C7e5BaAFBFFbca748158bEcBA61ef3b0a263;
        playerOne = 0xFeebabE6b0418eC13b30aAdF129F5DcDd4f70CeA;
        utils = new Utils(game, playerZero, playerOne);
    }

    // test return metadata matches pre-calculated base64 encoded string for single sided mint
    function testSingleSidedMintMetadata() public {
        uint256 gameID = game.createNewGame(playerZero, playerOne);
        uint256[9] memory turns = [uint256(1), 0, 3, 2, 4, 5, 6, 7, 8];
        utils.playGame(gameID, turns);
        game.mint{value: 0.005 ether}(gameID, 0);
        uint256 tokenID = (gameID << 160) | uint256(uint160(playerZero));
        string memory metadata = game.tokenURI(tokenID);
        console2.log(metadata);
    }

    function testAltSingleMint() public {
        uint256 gameID = game.createNewGame(playerZero, playerOne);
        uint256[9] memory turns = [uint256(1), 0, 3, 2, 4, 5, 6, 7, 8];
        utils.playGame(gameID, turns);
        game.mint{value: 0.005 ether}(gameID, 0);
        uint256 tokenID = (gameID << 160) | uint256(uint160(playerZero));
        string memory metadata = game.tokenURI(tokenID);
        string memory colors = game._getColors();
        console2.log(colors);
    }

    function testGetColors() public {


        IColormapRegistry COLOR_MAP_REGISTRY = IColormapRegistry(0x0000000012883D1da628e31c0FE52e35DcF95D50);
        /// @notice The base64 digits used for color pallete generation. 
        bytes32 SUMMER = 0x87970b686eb726750ec792d49da173387a567764d691294d764e53439359c436;
        string memory colorHex = COLOR_MAP_REGISTRY.getValueAsHexString({ _colormapHash: SUMMER, _position: 42 });
        console2.log(colorHex);
    }


    // test return metadata matches pre-calculated base64 encoded string for double sided mint
    function testDoubleSidedMintMetadata() public {
        uint256 gameID = game.createNewGame(playerZero, playerOne);
        uint256[9] memory turns = [uint256(1), 0, 3, 2, 4, 5, 6, 7, 8];
        utils.playGame(gameID, turns);
        game.mintForBothPlayers{value: 0.01 ether}(gameID);
        uint256 tokenID = (gameID << 160) | uint256(uint160(playerZero));
        string memory playerZeroMetadata = game.tokenURI(tokenID);
        console2.log(playerZeroMetadata);
        console2.log();
        tokenID = (gameID + 1 << 160) | uint256(uint160(playerOne));
        string memory playerOneMetadata = game.tokenURI(tokenID);
        console2.log(playerOneMetadata);
    }

    // test minting fails if game is not over for single and double sided mins
    function testMintingRejectBeforeGameOver() public {
        uint256 gameID = game.createNewGame(playerZero, playerOne);
        uint256[8] memory turns = [uint256(1), 0, 3, 2, 4, 5, 6, 7];
        utils.playGame(gameID, turns);
        vm.expectRevert(TicTacToe.GameNotOver.selector);
        game.mint{value: 0.005 ether}(gameID, 0);
    }

    // test minting fails if payment is too low for single and double sided mints
    function testMintingRejectLowPayment() public {
        uint256 gameID = game.createNewGame(playerZero, playerOne);
        uint256[9] memory turns = [uint256(1), 0, 3, 2, 4, 5, 6, 7, 8];
        utils.playGame(gameID, turns);
        vm.expectRevert(TicTacToe.IncorrectPayment.selector);
        game.mint{value: 0.004 ether}(gameID, 0);

        gameID = game.createNewGame(playerZero, playerOne);
        utils.playGame(gameID, turns);
        vm.expectRevert(TicTacToe.IncorrectPayment.selector);
        game.mintForBothPlayers{value: 0.009 ether}(gameID);
    }

    // test tokenURI fails for non-existent token 
    function testTokenURIFailsForNonExistentToken() public {
        uint256 gameID = game.createNewGame(playerZero, playerOne);
 
        vm.expectRevert(TicTacToe.TokenNotMinted.selector);
        game.tokenURI(0);

        vm.expectRevert(TicTacToe.TokenNotMinted.selector);
        game._tokenURI(gameID);

    }

    function testReMintingIsRejected() public {
        uint256 gameID = game.createNewGame(playerZero, playerOne);
        uint256[9] memory turns = [uint256(1), 0, 3, 2, 4, 5, 6, 7, 8];
        utils.playGame(gameID, turns);
        game.mint{value: 0.005 ether}(gameID, 0);
        vm.expectRevert(TicTacToe.TokenAlreadyMinted.selector);
        game.mint{value: 0.005 ether}(gameID, 0);
    }
}
