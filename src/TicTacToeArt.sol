// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Base64} from "src/Base64.sol";
import {Game} from "src/Game.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

/// @title A library that generates HTML art for TicTacToe
/// @author 0xcacti
/// @notice Below details how the metadata and art are generated:

/// ==============================================Name==============================================
/// Expressed as Python3 f-strings below, token names generate as
///                     ``f"0xcacti - Game #{game_id}, Result #{result}"''.
/// ==========================================Description===========================================
/// Token descriptions states player addresses and outcome in plain English.
/// ==============================================Art===============================================
/// The art is generated as HTML code with in-line CSS (0 JS) where color scheme is chosen off of
/// a seed value. The art is base 64-encoded and stored in the metadata.
/// ==========================================Attributes============================================
///

// "attributes": [
//     {
//         "trait_type": "Result",
//         "value": "Win"
//     },
//     {
//         "trait_type": "Player",
//         "value": "Player 0"
//     },
//     {
//         "trait_type": "Color Theme",
//         "value": "Nord"
//     },
//     {
//         "trait_type": "Color Generation",
//         "value": "Curated"
//     }
// ]

library TicTacToeArt {
    using Strings for uint256;
    using Game for uint256;

    bytes32 internal constant HEXADECIMAL_DIGITS = "0123456789ABCDEF";
    bytes32 internal constant FILE_NAMES = "abcdef";

    /// @notice Takes in data for a given TicTacToe NFT and outputs its metadata in JSON form.
    /// Refer to {TicTacToeArt} for details.
    /// @dev The output is base 64-encoded.
    /// @param gameBoard A bitpacked uint256 representing the game board (see Game.sol).
    /// @param playerZero The address of the player who plays as x
    /// @param playerOne The address of the player who plays as o
    /// @return Base 64-encoded JSON of metadata generated from `_internalId` and `_move`.
    function getMetadata(uint256 gameId, uint256 tokenId, uint256 gameBoard, address playerZero, address playerOne)
        internal
        pure
        returns (string memory)
    {
        // you need to resolve the fact that gameId does not decode which freaking player won and therefore which nft you are minting
        string memory name;
        string memory description;
        string memory image;
        string memory attributes;
        string memory colorScheme;
        string memory colorSchemeVariables;
        string memory generationMethod;

        (name, description) = getNameAndDescription(gameId, tokenId, gameBoard, playerZero, playerOne);

        // generate game description



        
        (colorScheme, colorSchemeVariables, generationMethod) = getColorScheme(uint256(keccak256(abi.encodePacked(gameId, tokenId, gameBoard))));

        image = getImage(gameBoard, colorSchemeVariables);
        attributes = string(
            abi.encodePacked(
                '[{"trait_type":"Color Theme","value":"',
                colorScheme, 
                '"},{"trait_type":"Color Generation","value":"',
                generationMethod,
                '"}]}'
            )
        );
        
        

            // return the ERC721 Metadata JSON Schema
            return string(
                // abi.encodePacked(
                //     "data:application/json;base64,",
                //     Base64.encode(
                abi.encodePacked(
                    '{"name":"',
                    name,
                    '","description":',
                    description,
                    '","image_url":"data:text/html;base64,',
                    image,
                    '"attributes":',
                    attributes
                )
            );
        
    }

    function getNameAndDescription(uint256 gameId, uint256 tokenId, uint256 gameBoard, address playerZero, address playerOne) internal pure returns (string memory, string memory) {
        string memory name;
        string memory description;
        {
            uint256 winner = gameBoard.getWinner();
            string memory p0 = Strings.toHexString(uint160(playerZero), 20);
            string memory p1 = Strings.toHexString(uint160(playerOne), 20);
            string memory gameNumber = Strings.toString( gameId / 2);
            if (winner == 3) {
                name = string(abi.encodePacked("Game #", gameNumber, ", Result: Draw"));
                description = string(abi.encodePacked("Game #", gameNumber, " - Player 0: ", p0, " vs Player 1: ", p1, " - Result: Draw"));
            } else if (winner == 1) {
                name = string(abi.encodePacked("0xcacti - Game #", gameNumber, ", Result: Player Zero Wins!"));
                description = string(abi.encodePacked("Game #", gameNumber, " - Player 0: ", p0, " vs Player 1: ", p1, " - Result: Player Zero Wins!"));
            } else {
                name = string(abi.encodePacked("0xcacti - Game #", gameNumber, ", Result: Player One Wins!"));
                description = string(abi.encodePacked("Game #", gameNumber, " - Player 0: ", p0,  " vs Player 1: ", p1, " - Result: Player One Wins!"));
            }
        }

        return (name, description);
    }

    function getColorScheme(uint256 _seed) internal pure returns (string memory, string memory, string memory) {
        uint256 colorTheme;
        string memory colorThemeName;
        string memory generationMethod;
        string memory colorThemeVariables;
        {
            if (_seed & 0x1F < 25) {
                generationMethod = "random";
                colorTheme = (_seed >> 5) & 0xFFFFFF;
                if (_seed & 0x1F < 7) {
                    colorTheme = (colorTheme << 0x60) | (colorTheme << 0x48) | (colorTheme << 0x30)
                        | (colorTheme << 0x18) | complementColor(colorTheme);
                } else if (_seed & 0x1F < 14) {
                    colorTheme = (darkenColor(colorTheme, 3) << 0x60) | (darkenColor(colorTheme, 1) << 0x48)
                        | (darkenColor(colorTheme, 2) << 0x30) | (colorTheme << 0x18) | complementColor(colorTheme);
                } else if (_seed & 0x1F < 21) {
                    colorTheme = (brightenColor(colorTheme, 3) << 0x60) | (brightenColor(colorTheme, 1) << 0x48)
                        | (brightenColor(colorTheme, 2) << 0x30) | (colorTheme << 0x18) | complementColor(colorTheme);
                } else if (_seed & 0x1F < 24) {
                    colorTheme =
                        (colorTheme << 0x60) | (0xFFFFFF << 0x48) | (colorTheme << 0x18) | complementColor(colorTheme);
                } else {
                    colorTheme =
                        (complementColor(colorTheme) << 0x60) | (colorTheme << 0x18) | complementColor(colorTheme);
                }
            } else {
                _seed >>= 5;
                generationMethod = "curated";
                colorThemeName = string(["Nord", "B/W", "Candycorn", "RGB", "VSCode", "Neon", "Jungle", "Corn"][_seed & 7]);
                colorTheme = [
                    0x8FBCBBEBCB8BD087705E81ACB48EAD000000FFFFFFFFFFFFFFFFFF000000,
                    0x0D3B66F4D35EEE964BFAF0CAF95738FFFF0000FF000000FFFF0000FFFF00,
                    0x1E1E1E569CD6D2D1A2BA7FB54DC4AC00FFFFFFFF000000FF00FF00FF00FF,
                    0xBE3400015045020D22EABAACBE3400F9C233705860211A28346830F9C233
                ][(_seed & 7) >> 1];
                colorTheme = _seed & 1 == 0 ? colorTheme >> 0x78 : colorTheme & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            }
            colorThemeVariables = string(
                abi.encodePacked(
                    "--e:",
                    toColorHexString(colorTheme >> 0x60),
                    ";--f:",
                    toColorHexString((colorTheme >> 0x48) & 0xFFFFFF),
                    ";--g:",
                    toColorHexString((colorTheme >> 0x30) & 0xFFFFFF),
                    ";--h:",
                    toColorHexString((colorTheme >> 0x18) & 0xFFFFFF),
                    ";--i:",
                    toColorHexString(colorTheme & 0xFFFFFF),
                    ";"
                )
            );
        }
        return (colorThemeName, colorThemeVariables, generationMethod);
    }

    function getImage(uint256 _board, string memory colorSchemeVariables) internal pure returns (string memory) {
        return string(abi.encodePacked('temp_image_string",'));
    }

    /// @notice Computes the complement of 24-bit colors.
    /// @param _color A 24-bit color.
    /// @return The complement of `_color`.
    function complementColor(uint256 _color) internal pure returns (uint256) {
        unchecked {
            return 0xFFFFFF - _color;
        }
    }

    /// @notice Darkens 24-bit colors.
    /// @param _color A 24-bit color.
    /// @param _num The number of shades to darken by.
    /// @return `_color` darkened `_num` times.
    function darkenColor(uint256 _color, uint256 _num) internal pure returns (uint256) {
        return
            (((_color >> 0x10) >> _num) << 0x10) | ((((_color >> 8) & 0xFF) >> _num) << 8) | ((_color & 0xFF) >> _num);
    }

    /// @notice Brightens 24-bit colors.
    /// @param _color A 24-bit color.
    /// @param _num The number of tints to brighten by.
    /// @return `_color` brightened `_num` times.
    function brightenColor(uint256 _color, uint256 _num) internal pure returns (uint256) {
        unchecked {
            return ((0xFF - ((0xFF - (_color >> 0x10)) >> _num)) << 0x10)
                | ((0xFF - ((0xFF - ((_color >> 8) & 0xFF)) >> _num)) << 8) | (0xFF - ((0xFF - (_color & 0xFF)) >> _num));
        }
    }

    /// @notice Returns the color hex string of a 24-bit color.
    /// @param _integer A 24-bit color.
    /// @return The color hex string of `_integer`.
    function toColorHexString(uint256 _integer) internal pure returns (string memory) {
        return string(
            abi.encodePacked(
                "#",
                HEXADECIMAL_DIGITS[(_integer >> 0x14) & 0xF],
                HEXADECIMAL_DIGITS[(_integer >> 0x10) & 0xF],
                HEXADECIMAL_DIGITS[(_integer >> 0xC) & 0xF],
                HEXADECIMAL_DIGITS[(_integer >> 8) & 0xF],
                HEXADECIMAL_DIGITS[(_integer >> 4) & 0xF],
                HEXADECIMAL_DIGITS[_integer & 0xF]
            )
        );
    }
}
