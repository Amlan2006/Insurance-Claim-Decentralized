// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Engine{
    mapping(uint256 => string) public claimIdToClaims;
    address[] public validators;
    address[] public policyHolders;
    address public admin;
    IERC20 public token;  // Token contract for payments

    struct PolicyTemplate {
        uint256 policyId;        // Unique ID for the policy template
        uint256 coverageAmount;  // Max payout if claim is valid
        uint256 startDate;       // Policy start time (timestamp)
        uint256 endDate;         // Policy expiry time
        string coverageType;     // Type (health, car, flight, crop etc.)
        bool isMonthly;          // Whether the policy is paid monthly
        uint256 monthlyPremium;  // Monthly premium amount
    }
    
    struct PolicyInstance {
        uint256 templateId;      // Reference to the policy template
        address policyHolder;    // Who bought the policy
        uint256 startDate;       // Instance start time (timestamp)
        uint256 endDate;         // Instance expiry time
        bool isActive;           // Whether policy is still active
        bool isClaimed;          // Whether a claim has already been made
        uint256 nextPaymentDate; // Next payment due date (for monthly policies)
        uint256 paymentsMade;    // Number of monthly payments made
    }
    
    struct Claim {
        uint256 claimId;         // Unique ID for the claim
        uint256 policyId;        // Policy instance ID
        string reason;           // Reason for the claim
        bool isApproved;         // Whether the claim is approved
        uint256 approvalCount;   // Number of validators who approved
        uint256 rejectionCount;  // Number of validators who rejected
        mapping(address => bool) hasVoted;  // Track which validators have voted
    }

    mapping(uint256 => PolicyTemplate) public policyTemplates;  // Store policy templates by ID
    mapping(uint256 => PolicyInstance) public policyInstances;  // Store policy instances by ID
    mapping(uint256 => Claim) public claims;  // Store claims by ID
    uint256 public nextInstanceId = 1;  // Counter for generating unique instance IDs
    uint256 public nextClaimId = 1;     // Counter for generating unique claim IDs

    PolicyTemplate[] public policyTemplateList;
    PolicyInstance[] public policyInstanceList;
    
    constructor(address _tokenAddress){
        admin = msg.sender;
        token = IERC20(_tokenAddress);  // Set the token contract address
    }   
    modifier onlyAdmin(){
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }
    modifier onlyValidator(){
        bool isValidator = false;
        for(uint i=0; i<validators.length; i++){
            if(validators[i] == msg.sender){
                isValidator = true;
                break;
            }
        }
        require(isValidator, "Only validator can perform this action");
        _;
    }
    modifier onlyPolicyHolder(){
        bool isPolicyHolder = false;
        for(uint i=0; i<policyHolders.length; i++){
            if(policyHolders[i] == msg.sender){
                isPolicyHolder = true;
                break;
            }
        }
        require(isPolicyHolder, "Only policy holder can perform this action");
        _;
    }
    function addValidator(address _validator) public onlyAdmin{
        validators.push(_validator);
    }
    function addPolicyHolder(address _policyHolder) public {
        policyHolders.push(_policyHolder);
    }
    
    // Policy holder function to file a claim
    function fileClaim(uint256 _policyId, string memory _reason) public onlyPolicyHolder returns (uint256) {
        // Check that policy instance exists and belongs to the caller
        require(policyInstances[_policyId].templateId != 0, "Policy instance does not exist");
        require(policyInstances[_policyId].policyHolder == msg.sender, "Not your policy");
        require(policyInstances[_policyId].isActive, "Policy is not active");
        require(!policyInstances[_policyId].isClaimed, "Claim already filed for this policy");
        
        // Create a new claim
        uint256 claimId = nextClaimId;
        nextClaimId++;
        
        Claim storage newClaim = claims[claimId];
        newClaim.claimId = claimId;
        newClaim.policyId = _policyId;
        newClaim.reason = _reason;
        newClaim.isApproved = false;
        newClaim.approvalCount = 0;
        newClaim.rejectionCount = 0;
        
        // Mark the policy as claimed
        policyInstances[_policyId].isClaimed = true;
        
        return claimId;
    }
    
    // Validator function to validate/approve a claim
    function validateClaim(uint256 _claimId, bool _approval) public onlyValidator {
        Claim storage claim = claims[_claimId];
        require(claim.claimId != 0, "Claim does not exist");
        require(!claim.hasVoted[msg.sender], "You have already voted on this claim");
        
        // Record the vote
        claim.hasVoted[msg.sender] = true;
        
        if (_approval) {
            claim.approvalCount++;
        } else {
            claim.rejectionCount++;
        }
        
        // Check if majority of validators have approved the claim
        uint256 totalValidators = validators.length;
        uint256 majority = totalValidators / 2 + 1;
        
        if (claim.approvalCount >= majority && !claim.isApproved) {
            claim.isApproved = true;
            
            // Transfer coverage amount to the policy holder
            PolicyInstance storage instance = policyInstances[claim.policyId];
            PolicyTemplate storage template = policyTemplates[instance.templateId];
            
            // Transfer tokens from contract to policy holder
            require(token.transfer(instance.policyHolder, template.coverageAmount), "Coverage payment failed");
        }
    }
    
    // Admin function to create policy templates with monthly premium
    function createPolicyTemplate(uint256 _policyId, uint256 _coverageAmount, uint256 _startDate, uint256 _endDate, string memory _coverageType, bool _isMonthly, uint256 _monthlyPremium) public{
        PolicyTemplate memory newTemplate = PolicyTemplate({
            policyId: _policyId,
            coverageAmount: _coverageAmount,
            startDate: _startDate,
            endDate: _endDate,
            coverageType: _coverageType,
            isMonthly: _isMonthly,
            monthlyPremium: _monthlyPremium
        });
        policyTemplates[_policyId] = newTemplate;
        policyTemplateList.push(newTemplate);
    }
    
    // Policy holder function to buy policies - creates a new instance
    function buyPolicy(uint256 _templateId) public onlyPolicyHolder returns (uint256) {
        // Check that policy template exists
        require(policyTemplates[_templateId].policyId != 0, "Policy template does not exist");
        
        // Get the policy template
        PolicyTemplate storage template = policyTemplates[_templateId];
        
        // Create a new policy instance
        uint256 instanceId = nextInstanceId;
        nextInstanceId++;
        
        PolicyInstance memory newInstance = PolicyInstance({
            templateId: _templateId,
            policyHolder: msg.sender,
            startDate: block.timestamp,
            endDate: template.endDate,
            isActive: true,
            isClaimed: false,
            nextPaymentDate: template.isMonthly ? block.timestamp + 30 days : 0,
            paymentsMade: 0
        });
        
        policyInstances[instanceId] = newInstance;
        policyInstanceList.push(newInstance);
        
        return instanceId;  // Return the new instance ID
    }
    
    // Function for policy holders to make monthly payments with token transfer
    function makeMonthlyPayment(uint256 _instanceId) public onlyPolicyHolder {
        PolicyInstance storage instance = policyInstances[_instanceId];
        require(instance.templateId != 0, "Policy instance does not exist");
        require(instance.policyHolder == msg.sender, "Not your policy");
        require(policyTemplates[instance.templateId].isMonthly, "Policy is not monthly");
        require(block.timestamp >= instance.nextPaymentDate, "Not yet due");
        require(instance.isActive, "Policy is not active");
        
        // Get the monthly premium amount from the policy template
        uint256 monthlyPremium = policyTemplates[instance.templateId].monthlyPremium;
        require(monthlyPremium > 0, "Monthly premium not set");
        
        // Transfer tokens from policy holder to contract
        require(token.transferFrom(msg.sender, address(this), monthlyPremium), "Token transfer failed");
        
        // Update the payment tracking
        instance.paymentsMade += 1;
        instance.nextPaymentDate = block.timestamp + 30 days;
        
        // Extend the policy end date
        instance.endDate = instance.endDate + 30 days;
    }
    
    // Function to get payment information for a policy
    function getPaymentInfo(uint256 _instanceId) public view returns (uint256 paymentsMade, uint256 nextPaymentDate, uint256 monthlyPremium) {
        PolicyInstance storage instance = policyInstances[_instanceId];
        require(instance.templateId != 0, "Policy instance does not exist");
        
        return (instance.paymentsMade, instance.nextPaymentDate, policyTemplates[instance.templateId].monthlyPremium);
    }
    
    // Function for policy holders to cancel their policies
    function cancelPolicy(uint256 _instanceId) public onlyPolicyHolder{
        PolicyInstance storage instance = policyInstances[_instanceId];
        require(instance.templateId != 0, "Policy instance does not exist");
        require(instance.policyHolder == msg.sender, "Not your policy");
        require(instance.isActive, "Policy is not active");
        
        instance.isActive = false;
    }
    
    // Function to get claim status
    function getClaimStatus(uint256 _claimId) public view returns (bool isApproved, uint256 approvalCount, uint256 rejectionCount) {
        Claim storage claim = claims[_claimId];
        require(claim.claimId != 0, "Claim does not exist");
        
        return (claim.isApproved, claim.approvalCount, claim.rejectionCount);
    }
    
    // Function for validators to get claim details including reason
    function getClaimDetails(uint256 _claimId) public view onlyValidator returns (uint256 policyId, string memory reason, bool isApproved) {
        Claim storage claim = claims[_claimId];
        require(claim.claimId != 0, "Claim does not exist");
        
        return (claim.policyId, claim.reason, claim.isApproved);
    }
    
    // Admin function to withdraw collected tokens
    function withdrawTokens(uint256 _amount) public onlyAdmin {
        require(token.transfer(admin, _amount), "Token transfer failed");
    }
    // Function to get all policy templates
    function getAllPolicyTemplates() public view returns (PolicyTemplate[] memory) {
        return policyTemplateList;
    }
    
}