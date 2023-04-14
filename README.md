# TicTacToe

Somewhat optimized tictactoe implementation in solidity. Heavily influenced by fiveoutofnine (tyvm).  

Optimization is to pack tictactoe games into 12 bytes of storage. 

Each game is represented as one uint256. The bytes are used as follows (indexing from left to right): 


| Byte Number | Pupose              |
| ----------- | ------------------- |
| 1           | turn count          |
| 2           | winner              |
| 3           | current turn        |
| 4  ->  12   | board               | 
| 13 ->       | Player Zero address | 



Hypothetically, you could represent many games per uint256, however, due to the need to track player addresses, this is less efficient (as far as I can tell). 

NFT Art is randomal generated based on the hash of the game identifier, game end state, and player address.  




