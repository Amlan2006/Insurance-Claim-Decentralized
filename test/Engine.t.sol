// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Engine.sol";
import "../src/TestToken.sol";

contract EngineTest is Test {
    Engine public engine;
    TestToken public token;
    address public admin = address(1);
    address public validator1 = address(2);
    address public validator2 = address(3);
    address public validator3 = address(4);
    address public policyHolder1 = address(5);
    address public policyHolder2 = address(6);

    function setUp() public {
        // Deploy test token with 1 million tokens
        vm.startPrank(admin);
        token = new TestToken(1000000 * 10**18);
        
        // Deploy engine contract
        engine = new Engine(address(token));
        
        // Add validators
        engine.addValidator(validator1);
        engine.addValidator(validator2);
        engine.addValidator(validator3);
        
        // Add policy holders
        engine.addPolicyHolder(policyHolder1);
        engine.addPolicyHolder(policyHolder2);
        
        // Mint tokens to users
        token.mint(policyHolder1, 10000 * 10**18);
        token.mint(policyHolder2, 10000 * 10**18);
        
        // Mint tokens to contract for claim payouts
        token.mint(address(engine), 100000 * 10**18);
        
        vm.stopPrank();
    }

    function testCreatePolicyTemplate() public {
        vm.startPrank(admin);
        engine.createPolicyTemplate(1, 5000 * 10**18, block.timestamp, block.timestamp + 365 days, "health", true, 100 * 10**18);
        vm.stopPrank();
        
        // Verify policy template was created
        (, uint256 coverageAmount, , , , bool isMonthly, uint256 monthlyPremium) = engine.policyTemplates(1);
        assertEq(coverageAmount, 5000 * 10**18);
        assertEq(isMonthly, true);
        assertEq(monthlyPremium, 100 * 10**18);
    }

    function testBuyPolicyAndMakePayment() public {
        // Create policy template
        vm.startPrank(admin);
        engine.createPolicyTemplate(1, 5000 * 10**18, block.timestamp, block.timestamp + 365 days, "health", true, 100 * 10**18);
        vm.stopPrank();
        
        // Buy policy
        vm.startPrank(policyHolder1);
        token.approve(address(engine), 100 * 10**18); // Approve monthly payment
        uint256 instanceId = engine.buyPolicy(1);
        vm.stopPrank();
        
        // Advance time by 30 days to make payment due
        vm.warp(block.timestamp + 30 days);
        
        // Make monthly payment
        vm.startPrank(policyHolder1);
        token.approve(address(engine), 100 * 10**18); // Approve another monthly payment
        engine.makeMonthlyPayment(instanceId);
        vm.stopPrank();
        
        // Check payment info
        (uint256 paymentsMade, , ) = engine.getPaymentInfo(instanceId);
        assertEq(paymentsMade, 1);
    }

    function testFileClaimAndValidate() public {
        // Create policy template
        vm.startPrank(admin);
        engine.createPolicyTemplate(1, 5000 * 10**18, block.timestamp, block.timestamp + 365 days, "health", true, 100 * 10**18);
        vm.stopPrank();
        
        // Buy policy
        vm.startPrank(policyHolder1);
        token.approve(address(engine), 100 * 10**18);
        uint256 instanceId = engine.buyPolicy(1);
        vm.stopPrank();
        
        // File claim
        vm.startPrank(policyHolder1);
        uint256 claimId = engine.fileClaim(instanceId, "Medical emergency");
        vm.stopPrank();
        
        // Validate claim with majority of validators
        vm.startPrank(validator1);
        engine.validateClaim(claimId, true);
        vm.stopPrank();
        
        vm.startPrank(validator2);
        engine.validateClaim(claimId, true);
        vm.stopPrank(); // This should trigger the payout since 2 out of 3 is majority
        
        // Check claim status
        (bool isApproved, uint256 approvalCount, ) = engine.getClaimStatus(claimId);
        assertEq(isApproved, true);
        assertEq(approvalCount, 2);
    }
}