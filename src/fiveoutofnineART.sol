// {
//             string memory tempAttribute;
//             uint256 colorTheme;
//             if (_seed & 0x1F < 25) {
//                 colorTheme = (_seed >> 5) & 0xFFFFFF;
//                 attributes = string(
//                     abi.encodePacked(
//                         attributes,
//                         ',{"trait_type":"Base Color","value":',
//                         colorTheme.toString(),
//                         "}"
//                     )
//                 );
//                 if (_seed & 0x1F < 7) {
//                     tempAttribute = "Uniform";
//                     colorTheme = (colorTheme << 0x60)
//                         | (colorTheme << 0x48)
//                         | (colorTheme << 0x30)
//                         | (colorTheme << 0x18)
//                         | complementColor(colorTheme);
//                 } else if (_seed & 0x1F < 14) {
//                     tempAttribute = "Shades";
//                     colorTheme = (darkenColor(colorTheme, 3) << 0x60)
//                         | (darkenColor(colorTheme, 1) << 0x48)
//                         | (darkenColor(colorTheme, 2) << 0x30)
//                         | (colorTheme << 0x18)
//                         | complementColor(colorTheme);
//                 } else if (_seed & 0x1F < 21) {
//                     tempAttribute = "Tints";
//                     colorTheme = (brightenColor(colorTheme, 3) << 0x60)
//                         | (brightenColor(colorTheme, 1) << 0x48)
//                         | (brightenColor(colorTheme, 2) << 0x30)
//                         | (colorTheme << 0x18)
//                         | complementColor(colorTheme);
//                 } else if (_seed & 0x1F < 24) {
//                     tempAttribute = "Eclipse";
//                     colorTheme = (colorTheme << 0x60)
//                         | (0xFFFFFF << 0x48)
//                         | (colorTheme << 0x18)
//                         | complementColor(colorTheme);
//                 } else {
//                     tempAttribute = "Void";
//                     colorTheme = (complementColor(colorTheme) << 0x60)
//                         | (colorTheme << 0x18)
//                         | complementColor(colorTheme);
//                 }
//             } else {
//                 tempAttribute = "Curated";
//                 _seed >>= 5;

//                 attributes = string(
//                     abi.encodePacked(
//                         attributes,
//                         ',{"trait_type":"Color Theme","value":"',
//                         ["Nord", "B/W", "Candycorn", "RGB", "VSCode", "Neon", "Jungle", "Corn"]
//                         [_seed & 7],
//                         '"}'
//                     )
//                 );

//                 colorTheme = [
//                     0x8FBCBBEBCB8BD087705E81ACB48EAD000000FFFFFFFFFFFFFFFFFF000000,
//                     0x0D3B66F4D35EEE964BFAF0CAF95738FFFF0000FF000000FFFF0000FFFF00,
//                     0x1E1E1E569CD6D2D1A2BA7FB54DC4AC00FFFFFFFF000000FF00FF00FF00FF,
//                     0xBE3400015045020D22EABAACBE3400F9C233705860211A28346830F9C233
//                 ][(_seed & 7) >> 1];
//                 colorTheme = _seed & 1 == 0
//                     ? colorTheme >> 0x78
//                     : colorTheme & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
//             }
//             attributes = string(
//                 abi.encodePacked(
//                     attributes,
//                     ',{"trait_type":"Color Generation","value":"',
//                     tempAttribute,
//                     '"}'
//                 )
//             );
//             styles = string(
//                 abi.encodePacked(
//                     styles,
//                     "--e:",
//                     toColorHexString(colorTheme >> 0x60),
//                     ";--f:",
//                     toColorHexString((colorTheme >> 0x48) & 0xFFFFFF),
//                     ";--g:",
//                     toColorHexString((colorTheme >> 0x30) & 0xFFFFFF),
//                     ";--h:",
//                     toColorHexString((colorTheme >> 0x18) & 0xFFFFFF),
//                     ";--i:",
//                     toColorHexString(colorTheme & 0xFFFFFF),
//                     ";"
//                 )
//             );
// }
