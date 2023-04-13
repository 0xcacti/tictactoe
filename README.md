# TicTacToe

Somewhat optimized tictactoe implementation in solidity. 
Heavily influenced by fiveoutofnine. 

### To Do 
- [x] Write core game logic 
- [x] Test core game logic 
- [x] Gas optimize core game logic
- [x] Generate CSS art 
- [x] Write Art generation contract 
- [ ] Fix colorscheme generation to be consistent
- [x] Test mint logic 
- [x] Test withdraws
- [ ] Test art generation logic 
- [x] Analyse with slither, halmos
- [ ] Write comments 
- [ ] Finish README 
- [ ] Compile and deploy on every chain at the same address.  
- [ ] Tweet



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

