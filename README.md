# TicTacToe

Somewhat optimized tictactoe implementation in solidity. 
Heavily influenced by fiveoutofnine. 

Each game is represented as one uint256.  The bytes are used as follows: 

   1  2  3  4  5  6  7  8  9 10 11 12 13 ->

0x00 00 00 00 00 00 00 00 00 00 00 00 0000000000000000000000000000000000000000 

| Byte Number | Pupose             |
| ----------- | ------------------ |
| 1           | turn count         |
| 2           | winner             |
| 3           | current turn       |
| 4  ->  12   | board              | 
| 13 ->       | 1st player address | 

You could represtent many games per board, however, due to the need to track player addresses, this is less efficient. 

Art is generated based on final state of the game using a random color scheme.  Art follows the following JSON metadata schema 

{

}

