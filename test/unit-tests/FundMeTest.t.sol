// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// attach flag -vv in forge test
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    // create a fake new address to send transactions here. So at least its easy to track the sender at the start of a test
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant GAS_PRICE = 1;

    // setUp always run first
    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, SEND_VALUE * 10);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    /**
     * if a chain is not specified (rpc-url), Foundry creates a new chain (with anvil) for the purpose of testing, and deletes after done
     * - since getVersion() - uses a static address, this will cause the revert, as the contract does not exist!
     * - run forge test -mt (or --match-test) <function-name> -v (multiple levels of verbose, -v, -vv, -vvv)
     *
     * Solution:
     * Tests
     * 1. Unit
     *  - test a specific part of code
     * 2. Integration
     * - test how our code works with other parts of code, code coverage
     * 3. Forked
     * - test code in a simulated environment
     * 4. Staging
     * - test code in a real test/dev environment
     *
     * To check test coverage:
     *  forge coverage --fork-url <rpc-url>
     */

    /**
     * Using Forked testing, from Alchemy node
     * forge test --match-test testPriceFeedVersionIsAccurate -vvvv --fork-url $SEPOLIA_RPC_URL
     *
     * Anvil takes a snapshot of the Sepolia Chain and simulates the actual environment locally. Calls are made to that node via HTTPS
     * - locally, anvil continues to produce blocks on top of the snapshot of the Sepolia Chain. This provides an isolated environment to test,
     *      which doesnt affect the Sepolia Chain
     * - through API calls, the local environment can still access real on-chain data
     *
     * check Alchemy dashboard after to see the API calls made to that node
     */
    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    // cheat code: expertRevert()
    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundedUpdatesFundedDataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        // set to USER
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // 0 will sometimes fail the sanity check, so best practice is start with 1

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // use address(i) to generate addresses
            // hoax basically does both prank and fund. But whats the difference then?
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        // uint256 gasStart = gasleft(); // how much gas left in transaction call
        // vm.txGasPrice(GAS_PRICE); //simulate gas price
        // explicitly state when the address initiates transactions
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw(); // spends gas
        vm.stopPrank();

        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        // console.log(gasUsed);

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        // Assert
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // 0 will sometimes fail the sanity check, so best practice is start with 1

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // use address(i) to generate addresses
            // hoax basically does both prank and fund. But whats the difference then?
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        // uint256 gasStart = gasleft(); // how much gas left in transaction call
        // vm.txGasPrice(GAS_PRICE); //simulate gas price
        // explicitly state when the address initiates transactions
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw(); // spends gas
        vm.stopPrank();

        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        // console.log(gasUsed);

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        // Assert
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    modifier funded() {
        // set the custom user for next transaction
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }
}
