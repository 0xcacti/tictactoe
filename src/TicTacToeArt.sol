// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Base64} from "src/Base64.sol";
import {Game} from "src/Game.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {IColormapRegistry} from "src/interfaces/IColormapRegistry.sol";

/// @title A library that generates HTML art for TicTacToe - Heavily influenced by fiveoutofnine
/// @author 0xcacti
/// @notice Below details how the metadata and art are generated:
/// @dev The art is generated as html code and base64-encoded.  The json metadata containing this
/// base64 encoded art is then also base64 encoded.  Through this method all image data is stored
/// entirely on chain.  The following fields are included in the metadata:
/// Name: The name of the NFT in the form `Game #{game_id}, Result #{result}`.
/// Description: The description of the NFT including game number, player addresses, and outcome.
/// Art: base64 html art with colorway generated from the gameID game board, and player address.
/// Attributes: Attributes include game result, player address, and colorway information.
library TicTacToeArt {
    using Game for uint256;
    /// @notice The base hex digits used for color pallete generation.
    bytes32 internal constant HEXADECIMAL_DIGITS = "0123456789ABCDEF";
    /// @notice address of the colormap registry used for fetching color schemes
    IColormapRegistry internal constant COLOR_MAP_REGISTRY =
        IColormapRegistry(0x0000000012883D1da628e31c0FE52e35DcF95D50);
    /// @notice The base64 digits used for color pallete fetching
    bytes32 internal constant CMRMAP =
        0x850ce48e7291439b1e41d21fc3f75dddd97580a4ff94aa9ebdd2bcbd423ea1e8;
    /// @notice The base64 digits used for color pallete fetching
    bytes32 internal constant WISTIA =
        0x4f5e8ea8862eff315c110b682ee070b459ba8983a7575c9a9c4c25007039109d;
    /// @notice The base64 digits used for color pallete fetching
    bytes32 internal constant AUTUMN =
        0xf2e92189cb6903b98d854cd74ece6c3fafdb2d3472828a950633fdaa52e05032;
    /// @notice The base64 digits used for color pallete fetching
    bytes32 internal constant BINARY =
        0xa33e6c7c5627ecabfd54c4d85f9bf04815fe89a91379fcf56ccd8177e086db21;
    /// @notice The base64 digits used for color pallete fetching
    bytes32 internal constant BONE =
        0xaa84b30df806b46f859a413cb036bc91466307aec5903fc4635c00a421f25d5c;
    /// @notice The base64 digits used for color pallete fetching
    bytes32 internal constant COOL =
        0x864a6ee98b9b21ac0291523750d637250405c24a6575e1f75cfbd7209a810ce6;
    /// @notice The base64 digits used for color pallete fetching
    bytes32 internal constant COPPER =
        0xfd60cd3811f002814944a7d36167b7c9436187a389f2ee476dc883e37dc76bd2;
    /// @notice The base64 digits used for color pallete fetching
    bytes32 internal constant GIST_RAINBOW =
        0xa8309447f8bd3b5e5e88a0abc05080b7682e4456c388b8636d45f5abb2ad2587;
    /// @notice The base64 digits used for color pallete fetching
    bytes32 internal constant GIST_STERN =
        0x3be719b0c342797212c4cb33fde865ed9cbe486eb67176265bc0869b54dee925;
    /// @notice The base64 digits used for color pallete fetching
    bytes32 internal constant GRAY =
        0xca0da6b6309ed2117508207d68a59a18ccaf54ba9aa329f4f60a77481fcf2027;
    /// @notice The base64 digits used for color pallete fetching
    bytes32 internal constant HOT =
        0x5ccb29670bb9de0e3911d8e47bde627b0e3640e49c3d6a88d51ff699160dfbe1;
    /// @notice The base64 digits used for color pallete fetching
    bytes32 internal constant HSV =
        0x3de8f27f386dab3dbab473f3cc16870a717fe5692b4f6a45003d175c559dfcba;
    /// @notice The base64 digits used for color pallete fetching
    bytes32 internal constant JET =
        0x026736ef8439ebcf8e7b8006bf8cb7482ced84d71b900407a9ed63e1b7bfe234;
    /// @notice The base64 digits used for color pallete fetching
    bytes32 internal constant SPRING =
        0xc1806ea961848ac00c1f20aa0611529da522a7bd125a3036fe4641b07ee5c61c;
    /// @notice The base64 digits used for color pallete fetching
    bytes32 internal constant SUMMER =
        0x87970b686eb726750ec792d49da173387a567764d691294d764e53439359c436;
    /// @notice The base64 digits used for color pallete fetching
    bytes32 internal constant TERRAIN =
        0xaa6277ab923279cf59d78b9b5b7fb5089c90802c353489571fca3c138056fb1b;
    /// @notice The base64 digits used for color pallete fetching
    bytes32 internal constant WINTER =
        0xdc1cecffc00e2f3196daaf53c27e53e6052a86dc875adb91607824d62469b2bf;

    /// @notice Takes in data for a given TicTacToe NFT and outputs its Base64-encoded metadata.
    /// @dev The output is base 64-encoded.
    /// @param gameBoard A bitpacked uint256 representing the game board.
    /// @param playerZero The address of the player who plays as x.
    /// @param playerOne The address of the player who plays as o.
    /// @return Base 64-encoded JSON metadata for the NFT.
    function getMetadata(
        uint256 gameID,
        uint256 tokenID,
        uint256 gameBoard,
        address playerZero,
        address playerOne
    ) internal view returns (string memory) {
        // you need to resolve the fact that gameID does not decode which freaking player won and therefore which nft you are minting
        string memory name;
        string memory description;
        string memory image;
        string memory attributes;
        string memory colorScheme;
        string memory colorSchemeVariables;

        (name, description) = getNameAndDescription(
            gameID,
            gameBoard,
            playerZero,
            playerOne
        );

        (
            colorScheme,
            colorSchemeVariables
        ) = getColorScheme(uint256(keccak256(abi.encodePacked(tokenID, gameBoard))));

        image = getImage(gameBoard, colorSchemeVariables);

        attributes = string(
            abi.encodePacked(
                '[{"trait_type":"Color Theme","value":"',
                colorScheme,
                '"}]}'
            )
        );

        // return the ERC721 Metadata JSON Schema
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        abi.encodePacked(
                            '{"name":"',
                            name,
                            '","description":',
                            description,
                            '","image_url":"data:text/html;base64,',
                            image,
                            '","attributes":',
                            attributes
                        )
                    )
                )
            );
    }

    /// @notice Takes in data for a given TicTacToe NFT and outputs its name and description for json metadata
    /// @param gameID The game ID
    /// @param gameBoard A bitpacked uint256 representing the game board (see Game.sol).
    /// @param playerZero The address of the player who plays as x
    /// @param playerOne The address of the player who plays as o
    /// @return name and description of the NFT
    function getNameAndDescription(
        uint256 gameID,
        uint256 gameBoard,
        address playerZero,
        address playerOne
    ) internal pure returns (string memory, string memory) {
        string memory name;
        string memory description;
        {
            uint256 winner = gameBoard.getWinner();
            string memory p0 = Strings.toHexString(uint160(playerZero), 20);
            string memory p1 = Strings.toHexString(uint160(playerOne), 20);
            string memory gameNumber = Strings.toString(gameID / 2);
            if (winner == 3) {
                name = string(
                    abi.encodePacked("Game #", gameNumber, ", Result: Draw")
                );
                description = string(
                    abi.encodePacked(
                        '"Game #',
                        gameNumber,
                        " - Player 0: ",
                        p0,
                        " vs Player 1: ",
                        p1,
                        " - Result: Draw"
                    )
                );
            } else if (winner == 1) {
                name = string(
                    abi.encodePacked(
                        "Game #",
                        gameNumber,
                        ", Result: Player Zero Wins!"
                    )
                );
                description = string(
                    abi.encodePacked(
                        '"Game #',
                        gameNumber,
                        " - Player 0: ",
                        p0,
                        " vs Player 1: ",
                        p1,
                        " - Result: Player Zero Wins!"
                    )
                );
            } else {
                name = string(
                    abi.encodePacked(
                        "Game #",
                        gameNumber,
                        ", Result: Player One Wins!"
                    )
                );
                description = string(
                    abi.encodePacked(
                        '"Game #',
                        gameNumber,
                        " - Player 0: ",
                        p0,
                        " vs Player 1: ",
                        p1,
                        " - Result: Player One Wins!"
                    )
                );
            }
        }

        return (name, description);
    }

    /// @notice Takes in data for a given TicTacToe NFT and generates a color scheme for the NFT using ColorMapRegistry
    /// @dev return variables are strings for the colorSchemeName, chemeVariables where the name is the name 
    /// from the registry and the variables are the CSS variables used in the HTML code. Color variables are taken 
    /// at even intervals from the color map returned by the registry.
    /// @param _seed A seed value for the color scheme generation
    /// @return colorScheme, colorSchemeVariables, colorThemeStyle
    function getColorScheme(
        uint256 _seed
    ) public view returns (string memory, string memory) {
        string memory colorThemeVariables;
        ( bytes32 colorMapHash, string memory colorThemeName) = getColorPalletHash(_seed);
        {
            string memory a = COLOR_MAP_REGISTRY.getValueAsHexString({
                _colormapHash: colorMapHash,
                _position: 0
            });
            string memory b = COLOR_MAP_REGISTRY.getValueAsHexString({
                _colormapHash: colorMapHash,
                _position: 85
            });
            string memory c = COLOR_MAP_REGISTRY.getValueAsHexString({
                _colormapHash: colorMapHash,
                _position: 170
            });
            string memory d = COLOR_MAP_REGISTRY.getValueAsHexString({
                _colormapHash: colorMapHash,
                _position: 255
            });
            colorThemeVariables = string(
                abi.encodePacked(
                    "--a: #",
                    a,
                    ";--b: #",
                    b,
                    ";--c: #",
                    c,
                    ";--d: #",
                    d,
                    ";"
                )
            );
        }
        return (colorThemeName, colorThemeVariables );
    }
    
    /// @notice Takes in a given seed and uses it to index into one of the color pallets in the registry
    /// @dev The color pallets hashes are stored as constants in the bytecode, this is just a few of the 
    /// possible pallets that can be used from the registry. The _seed value is used modulo the number of
    /// pallets with known hashes to select a pallet.
    /// @param _seed A seed value for selecting a hash
    /// @return colorMapHash, colorThemeName
    function getColorPalletHash(uint256 _seed) internal pure returns (bytes32, string memory) {
        uint256 index = _seed % 17;
        if (index == 0) return (CMRMAP, "cmrMAP");
        if (index == 1) return ( WISTIA, "wistia");
        if (index == 2) return ( AUTUMN, "autumn" );
        if (index == 3) return ( BINARY, "binary" );
        if (index == 4) return ( BONE, "bone" );
        if (index == 5) return ( COOL, "cool");
        if (index == 6) return ( COPPER, "copper" );
        if (index == 7) return ( GIST_RAINBOW, "gist_rainbow");
        if (index == 8) return ( GIST_STERN , "gist_stern");
        if (index == 9) return ( GRAY , "gray");
        if (index == 10) return ( HOT , "hot");
        if (index == 11) return ( HSV , "hsv");
        if (index == 12) return ( JET , "jet");
        if (index == 13) return ( SPRING , "spring");
        if (index == 14) return ( SUMMER , "summer");
        if (index == 15) return ( TERRAIN , "terrain");
        if (index == 16) return ( WINTER , "winter");
        return ( SUMMER , "summer");
    }

    /// @notice Takes in data for a given TicTacToe NFT and generates the html data for the image
    /// @dev crazy scoping is used to avoid stack too deep errors
    /// @param _board A bitpacked uint256 representing the game board (see Game.sol).
    /// @param colorSchemeVariables A string of CSS variables that are used in the HTML code
    /// @return image The html data for the image
    function getImage(
        uint256 _board,
        string memory colorSchemeVariables
    ) internal pure returns (string memory) {
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
                    " .x00Left {width: 100px;position: absolute;height: 10px;top: 45px;left: 1px;background: var(--d);rotate: 45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x00Right {width: 100px;position: absolute;height: 10px;top: 45px;left: 1px;background: var(--d);rotate: -45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x01Left {width: 100px;position: absolute;height: 10px;top: 45px;left: 101px;background: var(--d);rotate: 45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x01Right {width: 100px;position: absolute;height: 10px;top: 45px;left: 101px;background: var(--d);rotate: -45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x02Left {width: 100px;position: absolute;height: 10px;top: 45px;left: 201px;background: var(--d);rotate: 45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x02Right {width: 100px;position: absolute;height: 10px;top: 45px;left: 201px;background: var(--d);rotate: -45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}"
                )
            );
        }
        {
            image = string(
                abi.encodePacked(
                    image,
                    " .x10Left {width: 100px;position: absolute;height: 10px;top: 145px;left: 1px;background: var(--d);rotate: 45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x10Right {width: 100px;position: absolute;height: 10px;top: 145px;left: 1px;background: var(--d);rotate: -45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x11Left {width: 100px;position: absolute;height: 10px;top: 145px;left: 101px;background: var(--d);rotate: 45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x11Right {width: 100px;position: absolute;height: 10px;top: 145px;left: 101px;background: var(--d);rotate: -45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x12Left {width: 100px;position: absolute;height: 10px;top: 145px;left: 201px;background: var(--d);rotate: 45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x12Right {width: 100px;position: absolute;height: 10px;top: 145px;left: 201px;background: var(--d);rotate: -45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}"
                )
            );
        }
        {
            image = string(
                abi.encodePacked(
                    image,
                    " .x20Left {width: 100px;position: absolute;height: 10px;top: 245px;left: 1px;background: var(--d);rotate: 45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x20Right {width: 100px;position: absolute;height: 10px;top: 245px;left: 1px;background: var(--d);rotate: -45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x21Left {width: 100px;position: absolute;height: 10px;top: 245px;left: 101px;background: var(--d);rotate: 45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x21Right {width: 100px;position: absolute;height: 10px;top: 245px;left: 101px;background: var(--d);rotate: -45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x22Left {width: 100px;position: absolute;height: 10px;top: 245px;left: 201px;background: var(--d);rotate: 45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}",
                    " .x22Right {width: 100px;position: absolute;height: 10px;top: 245px;left: 201px;background: var(--d);rotate: -45deg;border-top-left-radius: 30px;border-top-right-radius: 30px;border-bottom-left-radius: 30px;border-bottom-right-radius: 30px;}"
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
            } else if (piece == 1) {
                // we're gonna place an x
                if (i == 0) {
                    image = string(
                        abi.encodePacked(
                            image,
                            "<div class='x00Left'></div>",
                            "<div class='x00Right'></div>"
                        )
                    );
                } else if (i == 1) {
                    image = string(
                        abi.encodePacked(
                            image,
                            "<div class='x01Left'></div>",
                            "<div class='x01Right'></div>"
                        )
                    );
                } else if (i == 2) {
                    image = string(
                        abi.encodePacked(
                            image,
                            "<div class='x02Left'></div>",
                            "<div class='x02Right'></div>"
                        )
                    );
                } else if (i == 3) {
                    image = string(
                        abi.encodePacked(
                            image,
                            "<div class='x10Left'></div>",
                            "<div class='x10Right'></div>"
                        )
                    );
                } else if (i == 4) {
                    image = string(
                        abi.encodePacked(
                            image,
                            "<div class='x11Left'></div>",
                            "<div class='x11Right'></div>"
                        )
                    );
                } else if (i == 5) {
                    image = string(
                        abi.encodePacked(
                            image,
                            "<div class='x12Left'></div>",
                            "<div class='x12Right'></div>"
                        )
                    );
                } else if (i == 6) {
                    image = string(
                        abi.encodePacked(
                            image,
                            "<div class='x20Left'></div>",
                            "<div class='x20Right'></div>"
                        )
                    );
                } else if (i == 7) {
                    image = string(
                        abi.encodePacked(
                            image,
                            "<div class='x21Left'></div>",
                            "<div class='x21Right'></div>"
                        )
                    );
                } else if (i == 8) {
                    image = string(
                        abi.encodePacked(
                            image,
                            "<div class='x22Left'></div>",
                            "<div class='x22Right'></div>"
                        )
                    );
                }
            } else if (piece == 2) {
                if (i == 0) {
                    image = string(
                        abi.encodePacked(image, "<div class='o00'></div>")
                    );
                } else if (i == 1) {
                    image = string(
                        abi.encodePacked(image, "<div class='o01'></div>")
                    );
                } else if (i == 2) {
                    image = string(
                        abi.encodePacked(image, "<div class='o02'></div>")
                    );
                } else if (i == 3) {
                    image = string(
                        abi.encodePacked(image, "<div class='o10'></div>")
                    );
                } else if (i == 4) {
                    image = string(
                        abi.encodePacked(image, "<div class='o11'></div>")
                    );
                } else if (i == 5) {
                    image = string(
                        abi.encodePacked(image, "<div class='o12'></div>")
                    );
                } else if (i == 6) {
                    image = string(
                        abi.encodePacked(image, "<div class='o20'></div>")
                    );
                } else if (i == 7) {
                    image = string(
                        abi.encodePacked(image, "<div class='o21'></div>")
                    );
                } else if (i == 8) {
                    image = string(
                        abi.encodePacked(image, "<div class='o22'></div>")
                    );
                }
            }
        }
        return
            string(
                Base64.encode(
                    abi.encodePacked(
                        "<style> :root { ",
                        colorSchemeVariables,
                        " } ",
                        image,
                        "</div></section>"
                    )
                )
            );
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
    function darkenColor(
        uint256 _color,
        uint256 _num
    ) internal pure returns (uint256) {
        return
            (((_color >> 0x10) >> _num) << 0x10) |
            ((((_color >> 8) & 0xFF) >> _num) << 8) |
            ((_color & 0xFF) >> _num);
    }

    /// @notice Brightens 24-bit colors.
    /// @param _color A 24-bit color.
    /// @param _num The number of tints to brighten by.
    /// @return `_color` brightened `_num` times.
    function brightenColor(
        uint256 _color,
        uint256 _num
    ) internal pure returns (uint256) {
        unchecked {
            return
                ((0xFF - ((0xFF - (_color >> 0x10)) >> _num)) << 0x10) |
                ((0xFF - ((0xFF - ((_color >> 8) & 0xFF)) >> _num)) << 8) |
                (0xFF - ((0xFF - (_color & 0xFF)) >> _num));
        }
    }

    /// @notice Returns the color hex string of a 24-bit color.
    /// @param _integer A 24-bit color.
    /// @return The color hex string of `_integer`.
    function toColorHexString(
        uint256 _integer
    ) internal pure returns (string memory) {
        return
            string(
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
