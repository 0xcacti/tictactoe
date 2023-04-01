// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import { Base64 } from "src/Base64.sol";
import { Game } from "src/Game.sol";
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
/// The art is generated as HTML code with in-line CSS (0 JS) according to the following table:
///  | Property       | Name      | Value/Description                       | Determination       |
///  | ============== | ========= | ======================================= | =================== |
///  | Dimension      | 1 × 1     | 1 × 1 pillars                           | Player moved king   |
///  | (6 traits)     | 2 × 2     | 2 × 2 pillars                           | Player moved rook   |
///  |                | 3 × 3     | 3 × 3 pillars                           | Engine moved bishop |
///  |                | 4 × 4     | 4 × 4 pillars                           | Player moved knight |
///  |                | 6 × 6     | 6 × 6 pillars                           | Player moved pawn   |
///  |                | 12 × 12   | 12 × 12 pillars                         | Player moved queen  |
///  | -------------- | --------- | --------------------------------------- | ------------------- |
///  | Height         | Plane     | 8px pillar height                       | 1 / 64 chance[^0]   |
///  | (5 traits)     | 1/4       | 98px pillar height                      | 10 / 64 chance[^0]  |
///  |                | 1/2       | 197px pillar height                     | 10 / 64 chance[^0]  |
///  |                | Cube      | 394px pillar height                     | 40 / 64 chance[^0]  |
///  |                | Infinite  | 1000px pillar height                    | 3 / 64 chance[^0]   |
///  | -------------- | --------- | --------------------------------------- | ------------------- |
///  | Gap[^1]        | None      | 0px gap between the pillars             | 4 / 16 chance[^0]   |
///  | (4 traits)     | Narrow    | 2px gap between the pillars             | 9 / 16 chance[^0]   |
///  |                | Wide      | 12px gap between the pillars            | 2 / 16 chance[^0]   |
///  |                | Ultrawide | 24px gap between the pillars            | 1 / 16 chance[^0]   |
///  | -------------- | --------- | --------------------------------------- | ------------------- |
///  | Color          | Uniform   | All faces are the same color            | 7 / 32 chance[^0]   |
///  | Generation[^2] | Shades    | Faces get darker anticlockwise          | 7 / 32 chance[^0]   |
///  | (6 traits)     | Tints     | Faces get lighter anticlockwise         | 7 / 32 chance[^0]   |
///  |                | Eclipse   | Left face is white; black face is black | 3 / 32 chance[^0]   |
///  |                | Void      | Left and right face are black           | 1 / 32 chance[^0]   |
///  |                | Curated   | One of 8 color themes (see below)       | 7 / 32 chance[^0]   |
///  | -------------- | --------- | --------------------------------------- | ------------------- |
///  | Color          | Nord      | 0x8FBCBBEBCB8BD087705E81ACB48EAD        | 1 / 8 chance[^0]    |
///  | Theme[^3]      | B/W       | 0x000000FFFFFFFFFFFFFFFFFF000000        | 1 / 8 chance[^0]    |
///  | (8 traits)     | Candycorn | 0x0D3B66F4D35EEE964BFAF0CAF95738        | 1 / 8 chance[^0]    |
///  |                | RGB       | 0xFFFF0000FF000000FFFF0000FFFF00        | 1 / 8 chance[^0]    |
///  |                | VSCode    | 0x1E1E1E569CD6D2D1A2BA7FB54DC4AC        | 1 / 8 chance[^0]    |
///  |                | Neon      | 0x00FFFFFFFF000000FF00FF00FF00FF        | 1 / 8 chance[^0]    |
///  |                | Jungle    | 0xBE3400015045020D22EABAACBE3400        | 1 / 8 chance[^0]    |
///  |                | Corn      | 0xF9C233705860211A28346830F9C233        | 1 / 8 chance[^0]    |
///  | -------------- | --------- | --------------------------------------- | ------------------- |
///  | Bit Border[^4] | True      | The bits have a 1px solid black border  | Any pieces captured |
///  | (2 traits)     | False     | The bits don't have any border          | No pieces captuered |
///  | ============== | ========= | ======================================= | =================== |
///  | [^0]: Determined from `_seed`.                                                             |
///  | [^1]: Gap is omitted when dimension is 1 x 1.                                              |
///  | [^2]: The first 5 color generation traits are algorithms. A base color is generated from   |
///  | `seed`, and the remaining colors are generated according to the selected algorithm. The    |
///  | color of the bits is always the complement of the randomly generated base color, and the   |
///  | background color depends on the algorithm:                                                 |
///  |     * Uniform: same as the base color;                                                     |
///  |     * Shades: darkest shade of the base color;                                             |
///  |     * Tints: lightest shade of the base color;                                             |
///  |     * Eclipse: same as the base color;                                                     |
///  |     * Void: complement of the base color.                                                  |
///  | If the selected color generation trait is "Curated," 1 of 8 pre-curated themes is randomly |
///  | selected.                                                                                  |
///  | [^3]: The entries in the 3rd column are bitpacked integers where                           |
///  |     * the first 24 bits represent the background color,                                    |
///  |     * the second 24 bits represent the left face's color,                                  |
///  |     * the third 24 bits represent the right face's color,                                  |
///  |     * the fourth 24 bits represent the top face's color,                                   |
///  |     * and the last 24 bits represent the bits' color.                                      |
///  | [^4]: Bit border is omitted when dimension is 12 x 12.                                     |

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
    function getMetadata(uint256 gameId, uint256 gameBoard, address playerZero, address playerOne)
        internal pure
        returns (string memory)
    {
        string memory description;
        string memory image;
        string memory attributes;
 




        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    abi.encodePacked(
                        '{"name":"Game #',
                        Strings.toString(gameId),
                        ", Result - ",
                        Strings.toString(),
                        '",'
                        '"description":"',
                        description,
                        '","data:image/png;base64,',
                        image,
                        '","attributes":[{"trait_type":"ColorScheme","value":',
                        colorScheme.toString(),
                        "},",
                        attributes,
                        "]}"
                    )
                )
            )
        );
    }

    /// @notice Generates the HTML image and its attributes for a given board and seed
    /// @dev The output of the image is base 64-encoded.
    /// @param gameBoard The end state of the tic-tac-toe board.
    /// @param _seed A hash of the game ID, board position, and metadata.
    /// @return Base 64-encoded image (in HTML) and its attributes.
    function getImage(uint256 _board, uint256 _seed)
        internal pure
        returns (string memory, string memory)
    {
        string memory attributes = string(
            abi.encodePacked(
                '{"trait_type":"Dimension","value":"',
                _numSquares.toString(),
                unicode" × ",
                _numSquares.toString(),
                '"}'
            )
        );
        string memory styles = string(
            abi.encodePacked(
                "<style>:root{--a:1000px;--b:",
                _numSquares.toString(),
                ";--c:"
            )
        );

        {
            string memory tempAttribute;
            string memory tempValue = "0";
            if (_numSquares != 1) {
                if (_seed & 0xF < 4) { (tempAttribute, tempValue) = ("None", "0"); }
                else if (_seed & 0xF < 13) { (tempAttribute, tempValue) = ("Narrow", "2"); }
                else if (_seed & 0xF < 15) { (tempAttribute, tempValue) = ("Wide", "12"); }
                else { (tempAttribute, tempValue) = ("Ultrawide", "24"); }

                attributes = string(
                    abi.encodePacked(
                        attributes,
                        ',{"trait_type":"Gap","value":"',
                        tempAttribute,
                        '"}'
                    )
                );
            }
            styles = string(abi.encodePacked(styles, tempValue, "px;--d:"));
        }
        _seed >>= 4;

        {
            string memory tempAttribute;
            string memory tempValue;
            if (_seed & 0x3F < 1) { (tempAttribute, tempValue) = ("Plane", "8"); }
            else if (_seed & 0x3F < 11) { (tempAttribute, tempValue) = ("1/4", "98"); }
            else if (_seed & 0x3F < 21) { (tempAttribute, tempValue) = ("1/2", "197"); }
            else if (_seed & 0x3F < 51) { (tempAttribute, tempValue) = ("Cube", "394"); }
            else { (tempAttribute, tempValue) = ("Infinite", "1000"); }

            attributes = string(
                abi.encodePacked(
                    attributes,
                    ',{"trait_type":"Height","value":"',
                    tempAttribute,
                    '"}'
                )
            );
            styles = string(abi.encodePacked(styles, tempValue, "px;"));
        }
        _seed >>= 6;

        {
            string memory tempAttribute;
            uint256 colorTheme;
            if (_seed & 0x1F < 25) {
                colorTheme = (_seed >> 5) & 0xFFFFFF;
                attributes = string(
                    abi.encodePacked(
                        attributes,
                        ',{"trait_type":"Base Color","value":',
                        colorTheme.toString(),
                        "}"
                    )
                );
                if (_seed & 0x1F < 7) {
                    tempAttribute = "Uniform";
                    colorTheme = (colorTheme << 0x60)
                        | (colorTheme << 0x48)
                        | (colorTheme << 0x30)
                        | (colorTheme << 0x18)
                        | complementColor(colorTheme);
                } else if (_seed & 0x1F < 14) {
                    tempAttribute = "Shades";
                    colorTheme = (darkenColor(colorTheme, 3) << 0x60)
                        | (darkenColor(colorTheme, 1) << 0x48)
                        | (darkenColor(colorTheme, 2) << 0x30)
                        | (colorTheme << 0x18)
                        | complementColor(colorTheme);
                } else if (_seed & 0x1F < 21) {
                    tempAttribute = "Tints";
                    colorTheme = (brightenColor(colorTheme, 3) << 0x60)
                        | (brightenColor(colorTheme, 1) << 0x48)
                        | (brightenColor(colorTheme, 2) << 0x30)
                        | (colorTheme << 0x18)
                        | complementColor(colorTheme);
                } else if (_seed & 0x1F < 24) {
                    tempAttribute = "Eclipse";
                    colorTheme = (colorTheme << 0x60)
                        | (0xFFFFFF << 0x48)
                        | (colorTheme << 0x18)
                        | complementColor(colorTheme);
                } else {
                    tempAttribute = "Void";
                    colorTheme = (complementColor(colorTheme) << 0x60)
                        | (colorTheme << 0x18)
                        | complementColor(colorTheme);
                }
            } else {
                tempAttribute = "Curated";
                _seed >>= 5;

                attributes = string(
                    abi.encodePacked(
                        attributes,
                        ',{"trait_type":"Color Theme","value":"',
                        ["Nord", "B/W", "Candycorn", "RGB", "VSCode", "Neon", "Jungle", "Corn"]
                        [_seed & 7],
                        '"}'
                    )
                );

                colorTheme = [
                    0x8FBCBBEBCB8BD087705E81ACB48EAD000000FFFFFFFFFFFFFFFFFF000000,
                    0x0D3B66F4D35EEE964BFAF0CAF95738FFFF0000FF000000FFFF0000FFFF00,
                    0x1E1E1E569CD6D2D1A2BA7FB54DC4AC00FFFFFFFF000000FF00FF00FF00FF,
                    0xBE3400015045020D22EABAACBE3400F9C233705860211A28346830F9C233
                ][(_seed & 7) >> 1];
                colorTheme = _seed & 1 == 0
                    ? colorTheme >> 0x78
                    : colorTheme & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            }
            attributes = string(
                abi.encodePacked(
                    attributes,
                    ',{"trait_type":"Color Generation","value":"',
                    tempAttribute,
                    '"}'
                )
            );
            styles = string(
                abi.encodePacked(
                    styles,
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

        {
            string memory tempAttribute;
            styles = string(
                abi.encodePacked(
                    styles,
                    SVG_STYLES,
                    Strings.toString(12 / _numSquares),
                    ",1fr);grid-template-rows:repeat(",
                    Strings.toString(12 / _numSquares),
                    ",1fr);transform:rotate(210deg)skew(-30deg)scaleY(0.864)}"
                )
            );
            if (_numSquares != 12) {
                if (_pieceCaptured) {
                    tempAttribute = "True";
                    styles = string(
                        abi.encodePacked(
                            styles,
                            ".c>*:nth-child(3)>div{border: 1px solid black}"
                        )
                    );
                } else {
                    tempAttribute = "False";
                }
                attributes = string(
                    abi.encodePacked(
                        attributes,
                        ',{"trait_type":"Bit Border","value":"',
                        tempAttribute,
                        '"}'
                    )
                );
            }
        }

        unchecked {
            for (uint256 i; i < 23; ++i) {
                styles = string(
                    abi.encodePacked(
                        styles,
                        ".r",
                        i.toString(),
                        "{top:calc(var(--o) + ",
                        i.toString(),
                        "*(var(--n)/2 + var(--c)))}"
                        ".c",
                        i.toString(),
                        "{left:calc(var(--p) ",
                        i < 11 ? "-" : "+",
                        " 0.866*",
                        i < 11 ? (11 - i).toString() : (i - 11).toString(),
                        "*(var(--n) + var(--c)))}"
                    )
                );
            }

            string memory image;
            for (uint256 row; row < (_numSquares << 1) - 1; ++row) {
                uint256 tempCol = row <= _numSquares - 1
                    ? 11 - row
                    : 11 - ((_numSquares << 1) - 2 - row);
                for (
                    uint256 col = tempCol;
                    col <= (row <= _numSquares - 1
                        ? tempCol + (row << 1)
                        : tempCol + (((_numSquares << 1) - 2 - row) << 1));
                    col = col + 2
                ) {
                    image = string(
                        abi.encodePacked(
                            image,
                            getPillarHtml(_board, 12 / _numSquares, row, col)
                        )
                    );
                }
            }

            return (
                Base64.encode(
                    abi.encodePacked(
                        styles,
                        "</style><section>",
                        image,
                        "</section>"
                    )
                ),
                attributes
            );
        }
    }

    /// @notice Returns the HTML for a particular pillar within the image.
    /// @param _board The board after the player's and engine's move are played.
    /// @param _dim The dimension of the bits within a pillar.
    /// @param _row The row index of the pillar.
    /// @param _col The column index of the pillar.
    /// @return The HTML for the pillar described by the parameters.
    function getPillarHtml(uint256 _board, uint256 _dim, uint256 _row, uint256 _col)
        internal pure
        returns (string memory)
    {
        string memory pillar = string(
            abi.encodePacked(
                '<div class="c r',
                _row.toString(),
                " c",
                _col.toString(),
                '"><div></div><div></div><div>'
            )
        );

        uint256 x;
        uint256 y;
        uint256 colOffset;
        uint256 rowOffset;
        unchecked {
            for (
                uint256 subRow = _row * _dim + ((_dim - 1) << 1);
                subRow >= _row * _dim + (_dim - 1);
                --subRow
            ) {
                rowOffset = 0;
                uint256 tempSubCol = _col <= 11
                    ? 11 - _dim * (11 - _col) + colOffset
                    : 11 + _dim * (_col - 11) + colOffset;
                for (
                    uint256 subCol = tempSubCol;
                    subCol >= tempSubCol + 1 - _dim;
                    --subCol
                ) {
                    x = 11 - ((11 + subCol - (subRow - rowOffset)) >> 1);
                    y = 16 - ((subCol + subRow - rowOffset) >> 1);
                    pillar = string(
                        abi.encodePacked(
                            pillar,
                            '<div id="',
                            (
                                _board
                                >> (Chess.getAdjustedIndex(6 * (y >> 1) + (x >> 1)) << 2)
                                >> (((0xD8 >> ((x & 1) << 2)) >> ((y & 1) << 1)) & 3)
                            )
                            & 1 == 0
                                ? "h"
                                : "i",
                            '"></div>'
                        )
                    );
                    rowOffset++;
                    if (subCol == 0) { break; }
                }
                colOffset++;
                if (subRow == 0) { break; }
            }
        }

        return string(abi.encodePacked(pillar, "</div></div>"));
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
        return (((_color >> 0x10) >> _num) << 0x10)
            | ((((_color >> 8) & 0xFF) >> _num) << 8)
            | ((_color & 0xFF) >> _num);
    }

    /// @notice Brightens 24-bit colors.
    /// @param _color A 24-bit color.
    /// @param _num The number of tints to brighten by.
    /// @return `_color` brightened `_num` times.
    function brightenColor(uint256 _color, uint256 _num) internal pure returns (uint256) {
        unchecked {
            return ((0xFF - ((0xFF - (_color >> 0x10)) >> _num)) << 0x10)
                | ((0xFF - ((0xFF - ((_color >> 8) & 0xFF)) >> _num)) << 8)
                | (0xFF - ((0xFF - (_color & 0xFF)) >> _num));
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