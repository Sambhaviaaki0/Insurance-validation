// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Insurance {

    enum PolicyType { Health, Vehicle, Property, Life }

    struct Policy {
        uint256 policyId;
        address policyHolder;
        PolicyType policyType;
        uint256 coverageAmount;
        uint256 premium;
        string startDate;
        string endDate;
        bool isClaimed;
    }

    uint256 public policyCounter;
    mapping(uint256 => Policy) public policies;
    mapping(address => uint256[]) public policyHolderPolicies;

    event PolicyCreated(
        uint256 policyId,
        address indexed policyHolder,
        PolicyType policyType,
        uint256 coverageAmount,
        uint256 premium,
        string startDate,
        string endDate
    );

    event ClaimValidated(
        uint256 policyId,
        address indexed policyHolder,
        bool isClaimed
    );

    constructor() {
        policyCounter = 0;
    }

    function createPolicy(
        PolicyType _policyType,
        uint256 _coverageAmount,
        uint256 _premium,
        string memory _startDate,
        string memory _endDate
    ) external {
        // Ensure the end date is after the start date
        // Note: Solidity cannot compare strings directly,
        // so you would need to handle date comparison off-chain or in a separate function.
        
        policyCounter++;
        policies[policyCounter] = Policy({
            policyId: policyCounter,
            policyHolder: msg.sender,
            policyType: _policyType,
            coverageAmount: _coverageAmount,
            premium: _premium,
            startDate: _startDate,
            endDate: _endDate,
            isClaimed: false
        });

        policyHolderPolicies[msg.sender].push(policyCounter);

        emit PolicyCreated(
            policyCounter,
            msg.sender,
            _policyType,
            _coverageAmount,
            _premium,
            _startDate,
            _endDate
        );
    }

    function validateClaim(uint256 _policyId) external {
        Policy storage policy = policies[_policyId];
        require(policy.policyHolder == msg.sender, "You are not the policy holder");
        // Solidity cannot compare dates as strings, so you would need to handle this off-chain.
        // require(block.timestamp >= policy.startDate, "Policy is not yet active");
        // require(block.timestamp <= policy.endDate, "Policy has expired");
        require(!policy.isClaimed, "Policy has already been claimed");

        policy.isClaimed = true;

        emit ClaimValidated(_policyId, msg.sender, true);
    }

    function getPoliciesByHolder(address _policyHolder) external view returns (uint256[] memory) {
        return policyHolderPolicies[_policyHolder];
    }

    function getPolicyDetails(uint256 _policyId) external view returns (
        uint256,
        address,
        PolicyType,
        uint256,
        uint256,
        string memory,
        string memory,
        bool
    ) {
        Policy storage policy = policies[_policyId];
        return (
            policy.policyId,
            policy.policyHolder,
            policy.policyType,
            policy.coverageAmount,
            policy.premium,
            policy.startDate,
            policy.endDate,
            policy.isClaimed
        );
    }
}