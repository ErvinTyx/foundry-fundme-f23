//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundme;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 10e18;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;


    // in testing setup runs first then only testDemo
    function setUp() external {
        // us -> FundMeTest -> FundMe
        //fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundme = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view{
        assertEq(fundme.MINIMUM_USD(),5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundme.getOwner(),msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view{
        uint256 version = fundme.getVersion();   
        console.log("Price feed version:", version);
        if(block.chainid == 31337){
            assertEq(version,4);
        }
        else if(block.chainid == 1){
            assertEq(version,6);
        }
        else{
            assertEq(version,4);
        }
        
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();// hey, the next line, should revert!
        // assert(This tx fails/reverts)
        fundme.fund();//send 0 value
    }

    function testFundUpdatesTheAmountFunded()  public funded{

        uint256 amountFunded = fundme.getAddressToAmountFunded(address(USER));
        assertEq(amountFunded,SEND_VALUE);

        
    }

    function testAddsFunderToArrayOfFunders() public funded{

        address funder = fundme.getFunder(0);
        assertEq(funder,USER);
    }

    function testOnlyOwnerCanWithdraw()  public funded{        
        vm.prank(USER);
        vm.expectRevert();
        fundme.withdraw();
    }

    modifier funded(){
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        _;
    }

    function testWithDrawWithASingleFunder() public funded{
        //Arrange
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;
        
        //Act
        vm.prank(fundme.getOwner());
        fundme.withdraw();
        
        //Ascert
        uint256 endingOwnerBalance = fundme.getOwner().balance;
        uint256 endingFundMeBalance = address(fundme).balance;
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
        assertEq(endingFundMeBalance, 0);
    }

    function testWithDrawFromMultipleFunder() public funded{
        uint160 numberOfFunders = 5;
        uint160 startingFunderIndex =1;
        

        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            hoax(address(i),SEND_VALUE);
            fundme.fund{value:SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        
        vm.prank(fundme.getOwner());
        fundme.withdraw();
        
        

        //Ascert
        
        assertEq(address(fundme).balance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance , fundme.getOwner().balance);
    }

    function testWithDrawFromMultipleFunderCheaper() public funded{
        uint160 numberOfFunders = 5;
        uint160 startingFunderIndex =1;
        

        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            hoax(address(i),SEND_VALUE);
            fundme.fund{value:SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        
        vm.prank(fundme.getOwner());
        fundme.cheaperWithdraw();
        
        

        //Ascert
        
        assertEq(address(fundme).balance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance , fundme.getOwner().balance);
    }
    

    // what can we do to work with address outside our system?
    // 1.unit
    // -- Testin a specific part of our code
    // 2.Integration
    // -- Testing how our code works with other part of our code
    // 3.Forked
    // -- Testing our code on a simulated real enviroment
    // 4.Staging
    // -- Testing our code in a real environment that is not prod
}