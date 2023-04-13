// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/TicTacToe.sol";
import "test/Utils.sol";
import {Game} from "src/Game.sol";

contract WithdrawTest is Test {
    TicTacToe game;
    address playerZero;
    address playerOne;
    address owner;
    Utils utils;

    function setUp() public {
        game = new TicTacToe();
        playerZero = 0x4675C7e5BaAFBFFbca748158bEcBA61ef3b0a263;
        playerOne = 0xFeebabE6b0418eC13b30aAdF129F5DcDd4f70CeA;
        owner = 0xB95777719Ae59Ea47A99e744AfA59CdcF1c410a1;
        utils = new Utils(game, playerZero, playerOne);
    }

    // test that the owner can withdraw funds even for strange value like zero
    function testWithdrawSucceedsOnZeroBalance() public {
        vm.prank(owner);
        game.withdraw();
    }

    // test that non-owner cannot withdraw funds
    function testWithdrawFailsFromNonOwner() public {
        vm.expectRevert();
        game.withdraw();
    }

    function testWithdrawSucceedsOnNonZeroBalance() public {
        uint256 gameID = game.createNewGame(playerZero, playerOne);
        uint256[5] memory turns = [uint256(0), 3, 1, 4, 2];
        utils.playGame(gameID, turns);
        game.mintForBothPlayers{value: 0.01 ether}(gameID);

        vm.prank(owner);
        game.withdraw();
        assertEq(owner.balance, 0.01 ether);
    }

    
}
