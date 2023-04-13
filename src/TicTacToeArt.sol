// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Base64} from "src/Base64.sol";
import {Game} from "src/Game.sol";
import {LibString} from "solmate/utils/LibString.sol";
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
    using LibString for uint256;
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
    function getMetadata(uint256 gameID, uint256 tokenID, uint256 gameBoard, address playerZero, address playerOne)
        internal
        view
        returns (string memory)
    {
        // you need to resolve the fact that gameID does not decode which freaking player won and therefore which nft you are minting
        string memory name;
        string memory description;
        string memory image;
        string memory attributes;
        string memory colorScheme;
        string memory colorSchemeVariables;
        string memory generationMethod;

        (name, description) = getNameAndDescription(gameID, tokenID, gameBoard, playerZero, playerOne);

        (colorScheme, colorSchemeVariables, generationMethod) = getColorScheme(uint256(keccak256(abi.encodePacked(gameID, tokenID, gameBoard, block.difficulty))));
       
        image = getImage(gameBoard, colorSchemeVariables);
        image = string(
            abi.encodePacked(
                "<style> :root { ",
                colorSchemeVariables,
                " } ",
                image
            )
        );


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

    function getNameAndDescription(uint256 gameID, uint256 tokenID, uint256 gameBoard, address playerZero, address playerOne) internal pure returns (string memory, string memory) {
        string memory name;
        string memory description;
        {
            uint256 winner = gameBoard.getWinner();
            string memory p0 = Strings.toHexString(uint160(playerZero), 20);
            string memory p1 = Strings.toHexString(uint160(playerOne), 20);
            string memory gameNumber = Strings.toString( gameID / 2);
            if (winner == 3) {
                name = string(abi.encodePacked("Game #", gameNumber, ", Result: Draw"));
                description = string(abi.encodePacked("Game #", gameNumber, " - Player 0: ", p0, " vs Player 1: ", p1, " - Result: Draw"));
            } else if (winner == 1) {
                name = string(abi.encodePacked("Game #", gameNumber, ", Result: Player Zero Wins!"));
                description = string(abi.encodePacked("Game #", gameNumber, " - Player 0: ", p0, " vs Player 1: ", p1, " - Result: Player Zero Wins!"));
            } else {
                name = string(abi.encodePacked("Game #", gameNumber, ", Result: Player One Wins!"));
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
                colorThemeName = Strings.toHexString(colorTheme, 15);
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
                    "--a:",
                    toColorHexString(colorTheme >> 0x60),
                    ";--b:",
                    toColorHexString((colorTheme >> 0x48) & 0xFFFFFF),
                    ";--c:",
                    toColorHexString((colorTheme >> 0x30) & 0xFFFFFF),
                    ";--d:",
                    toColorHexString((colorTheme >> 0x18) & 0xFFFFFF),
                    ";--e:",
                    toColorHexString(colorTheme & 0xFFFFFF),
                    ";"
                )
            );
        }

       //  0x000000000000000000 1c1719 735d65 392e32 e7bacb 184534
      // 0xfde8e1 f4a386 fad1c3 e8460d 17b9f2
        return (colorThemeName, colorThemeVariables, generationMethod);
    }

    function getImage(uint256 _board, string memory colorSchemeVariables) internal pure returns (string memory) {
        string memory image;
        {
            image = string(
                abi.encodePacked(
                    image,
                    "body {background: var(--a);} .container { position: fixed;top: 0;bottom: 0;left: 0;right: 0;margin: auto;height: 300px;width: 300px;flex-direction: column;}", 
                    " .crossVerticalLeft {width: 8px;position: absolute;height: 100%;left: 95px;background: var(--b);border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .crossHorizontalTop {width: 100%;position: absolute;height: 8px;top: 95px;background: var(--b);border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .crossHorizontalBottom {width: 100%;position: absolute;height: 8px;top: 195px;background: var(--b);border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .crossVerticalRight {width: 8px;position: absolute;left: 195px;height: 100%;background: var(--b);border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}"
                )
            );
        }
        {
            image = string(
                abi.encodePacked(
                    image,
                    " .o00 {position: absolute;border: 25px solid var(--c);top: 10px;left: 10px;border-radius: 100px;height: 30px;width: 30px;}",
                    " .o01 {position: absolute;border: 25px solid var(--c);top: 10px;left: 110px;border-radius: 100px;height: 30px;width: 30px;}",
                    " .o02 {position: absolute;border: 25px solid var(--c);top: 10px;left: 210px;border-radius: 100px;height: 30px;width: 30px;}",
                    " .o10 {position: absolute;border: 25px solid var(--c);top: 110px;left: 10px;border-radius: 100px;height: 30px;width: 30px;}",
                    " .o11 {position: absolute;border: 25px solid var(--c);top: 110px;left: 110px;border-radius: 100px;height: 30px;width: 30px;}",
                    " .o12 {position: absolute;border: 25px solid var(--c);top: 110px;left: 210px;border-radius: 100px;height: 30px;width: 30px;}",
                    " .o20 {position: absolute;border: 25px solid var(--c);top: 210px;left: 10px;border-radius: 100px;height: 30px;width: 30px;}",
                    " .o21 {position: absolute;border: 25px solid var(--c);top: 210px;left: 110px;border-radius: 100px;height: 30px;width: 30px;}",
                    " .o22 {position: absolute;border: 25px solid var(--c);top: 210px;left: 210px;border-radius: 100px;height: 30px;width: 30px;}"
                )
            );
        }

        {
            image = string(
                abi.encodePacked(
                    image,
                    " .x00Left {width: 100px;position: absolute;height: 10px;top: 45px;left: 1px;background: var(--e);rotate: 45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x00Right {width: 100px;position: absolute;height: 10px;top: 45px;left: 1px;background: var(--e);rotate: -45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x01Left {width: 100px;position: absolute;height: 10px;top: 45px;left: 101px;background: var(--e);rotate: 45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x01Right {width: 100px;position: absolute;height: 10px;top: 45px;left: 101px;background: var(--e);rotate: -45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x02Left {width: 100px;position: absolute;height: 10px;top: 45px;left: 201px;background: var(--e);rotate: 45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x02Right {width: 100px;position: absolute;height: 10px;top: 45px;left: 201px;background: var(--e);rotate: -45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}"
                )
            );
        }
        {
            image = string(
                abi.encodePacked(
                    image,
                    " .x10Left {width: 100px;position: absolute;height: 10px;top: 145px;left: 1px;background: var(--e);rotate: 45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x10Right {width: 100px;position: absolute;height: 10px;top: 145px;left: 1px;background: var(--e);rotate: -45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x11Left {width: 100px;position: absolute;height: 10px;top: 145px;left: 101px;background: var(--e);rotate: 45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x11Right {width: 100px;position: absolute;height: 10px;top: 145px;left: 101px;background: var(--e);rotate: -45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x12Left {width: 100px;position: absolute;height: 10px;top: 145px;left: 201px;background: var(--e);rotate: 45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x12Right {width: 100px;position: absolute;height: 10px;top: 145px;left: 201px;background: var(--e);rotate: -45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}"
                )
            );
        }
        {
            image = string(
                abi.encodePacked(
                    image,
                    " .x20Left {width: 100px;position: absolute;height: 10px;top: 245px;left: 1px;background: var(--e);rotate: 45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x20Right {width: 100px;position: absolute;height: 10px;top: 245px;left: 1px;background: var(--e);rotate: -45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x21Left {width: 100px;position: absolute;height: 10px;top: 245px;left: 101px;background: var(--e);rotate: 45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x21Right {width: 100px;position: absolute;height: 10px;top: 245px;left: 101px;background: var(--e);rotate: -45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x22Left {width: 100px;position: absolute;height: 10px;top: 245px;left: 201px;background: var(--e);rotate: 45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x22Right {width: 100px;position: absolute;height: 10px;top: 245px;left: 201px;background: var(--e);rotate: -45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}"
                )
            );
        }

        image = string(
            abi.encodePacked(
                image, 
                "</style>", 
                "<section><div class='container'><div class='crossVerticalLeft'></div><div class='crossVerticalRight'></div><div class='crossHorizontalTop'></div><div class='crossHorizontalBottom'></div>"
                )
            );
        
        uint256 piece = 0;
        for (uint256 i = 0; i < 9; i++) {
            piece = (_board >> (i * 8)) & 0xff; // do I need the whole byte
            if (piece == 0) {
                continue;
            } else if (piece == 1) { // we're gonna place an x
                if (i == 0) {
                    image = string(abi.encodePacked(image, "<div class='x00Left'></div>", "<div class='x00Right'></div>"));
                } else if (i == 1) {
                    image = string(abi.encodePacked(image, "<div class='x01Left'></div>", "<div class='x01Right'></div>"));
                } else if (i == 2) {
                    image = string(abi.encodePacked(image, "<div class='x02Left'></div>", "<div class='x02Right'></div>"));
                } else if (i == 3) {
                    image = string(abi.encodePacked(image, "<div class='x10Left'></div>", "<div class='x10Right'></div>"));
                } else if (i == 4) {
                    image = string(abi.encodePacked(image, "<div class='x11Left'></div>", "<div class='x11Right'></div>"));
                } else if (i == 5) {
                    image = string(abi.encodePacked(image, "<div class='x12Left'></div>", "<div class='x12Right'></div>"));
                } else if (i == 6) {
                    image = string(abi.encodePacked(image, "<div class='x20Left'></div>", "<div class='x20Right'></div>"));
                } else if (i == 7) {
                    image = string(abi.encodePacked(image, "<div class='x21Left'></div>", "<div class='x21Right'></div>"));
                } else if (i == 8) {
                    image = string(abi.encodePacked(image, "<div class='x22Left'></div>", "<div class='x22Right'></div>"));
                }

            } else if (piece == 2) {
                if (i == 0) {
                    image = string(abi.encodePacked(image, "<div class='o00'></div>"));
                } else if (i == 1) {
                    image = string(abi.encodePacked(image, "<div class='o01'></div>"));
                } else if (i == 2) {
                    image = string(abi.encodePacked(image, "<div class='o02'></div>"));
                } else if (i == 3) {
                    image = string(abi.encodePacked(image, "<div class='o10'></div>"));
                } else if (i == 4) {
                    image = string(abi.encodePacked(image, "<div class='o11'></div>"));
                } else if (i == 5) {
                    image = string(abi.encodePacked(image, "<div class='o12'></div>"));
                } else if (i == 6) {
                    image = string(abi.encodePacked(image, "<div class='o20'></div>"));
                } else if (i == 7) {
                    image = string(abi.encodePacked(image, "<div class='o21'></div>"));
                } else if (i == 8) {
                    image = string(abi.encodePacked(image, "<div class='o22'></div>"));
                }
            }

        }

        return string(abi.encodePacked(image, "</div></section>"));
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
