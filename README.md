# ComplianceOfficer

ComplianceOfficer is a decentralized address reputation system smart contract designed for tracking and scoring regulatory compliance officer effectiveness on the Stacks blockchain. This contract provides a transparent, immutable system for managing compliance officer reputation scores and assessment history.

## Features

- **Officer Registration**: Register new compliance officers with initial reputation scores
- **Score Management**: Update compliance scores with detailed reasoning and audit trails
- **Assessment History**: Maintain comprehensive records of all score changes and assessments
- **Reputation Levels**: Automatic categorization based on performance scores (excellent, good, satisfactory, poor, critical)
- **Authorization System**: Role-based access control for assessors and administrators
- **Emergency Controls**: Contract pause/resume functionality for emergency situations
- **Audit Trail**: Complete transparency with block-height tracking and assessment history

## Technical Specifications

- **Blockchain**: Stacks
- **Language**: Clarity
- **Version**: 1.0.0
- **Clarity Version**: 2
- **Epoch**: 2.5

### Score System

- **Range**: 0-100 points
- **Initial Score**: 50 points for new officers
- **Reputation Levels**:
  - Excellent: 90-100 points
  - Good: 75-89 points
  - Satisfactory: 60-74 points
  - Poor: 40-59 points
  - Critical: 0-39 points

## Installation

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks smart contract development tool
- Node.js and npm for running tests

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd ComplianceOfficer
```

2. Navigate to the contract directory:
```bash
cd ComplianceOfficer_contract
```

3. Install dependencies:
```bash
npm install
```

4. Run tests:
```bash
npm test
```

## Usage Examples

### Deploy Contract

```bash
clarinet integrate
```

### Basic Operations

#### Register a New Officer
```clarity
(contract-call? .ComplianceOfficer register-officer 'SP1EXAMPLE...)
```

#### Update Officer Score
```clarity
(contract-call? .ComplianceOfficer update-score 'SP1EXAMPLE... u85 "Excellent compliance during Q1 audit")
```

#### Get Officer Information
```clarity
(contract-call? .ComplianceOfficer get-officer-info 'SP1EXAMPLE...)
```

#### Check Reputation Level
```clarity
(contract-call? .ComplianceOfficer get-reputation-level 'SP1EXAMPLE...)
```

## Contract Functions Documentation

### Public Functions

#### Administrative Functions

- **`add-assessor (assessor principal)`**
  - Adds an authorized assessor (owner only)
  - Returns: `(response bool uint)`

- **`remove-assessor (assessor principal)`**
  - Removes an authorized assessor (owner only)
  - Returns: `(response bool uint)`

- **`pause-contract ()`**
  - Emergency pause functionality (owner only)
  - Returns: `(response bool uint)`

- **`resume-contract ()`**
  - Resume paused contract (owner only)
  - Returns: `(response bool uint)`

#### Officer Management Functions

- **`register-officer (officer principal)`**
  - Registers a new compliance officer
  - Initial score: 50 points
  - Requires: Authorized assessor
  - Returns: `(response bool uint)`

- **`update-score (officer principal) (new-score uint) (reason string-ascii)`**
  - Updates officer's compliance score (0-100)
  - Records assessment history
  - Requires: Authorized assessor
  - Returns: `(response bool uint)`

- **`update-officer-status (officer principal) (new-status string-ascii)`**
  - Updates officer status (active, inactive, suspended, etc.)
  - Requires: Authorized assessor
  - Returns: `(response bool uint)`

### Read-Only Functions

#### Officer Information

- **`get-officer-info (officer principal)`**
  - Returns complete officer data structure
  - Returns: `(optional {...})`

- **`get-officer-score (officer principal)`**
  - Returns current officer score
  - Returns: `(response uint uint)`

- **`get-reputation-level (officer principal)`**
  - Returns reputation level string based on score
  - Returns: `(response string-ascii uint)`

- **`is-registered-officer (officer principal)`**
  - Checks if officer is registered
  - Returns: `bool`

#### Assessment History

- **`get-assessment-history (officer principal) (assessment-id uint)`**
  - Returns specific assessment record
  - Returns: `(optional {...})`

- **`get-officer-assessment-count (officer principal)`**
  - Returns total assessment count for officer
  - Returns: `uint`

#### Contract Status

- **`get-contract-paused ()`**
  - Returns contract pause status
  - Returns: `bool`

- **`get-total-officers ()`**
  - Returns total registered officers count
  - Returns: `uint`

- **`is-authorized-assessor (assessor principal)`**
  - Checks if address is authorized assessor
  - Returns: `bool`

- **`get-contract-owner ()`**
  - Returns contract owner address
  - Returns: `principal`

## Deployment Guide

### Local Development

1. Start Clarinet console:
```bash
clarinet console
```

2. Deploy contract:
```clarity
::deploy_contract contracts/ComplianceOfficer.clar
```

### Testnet Deployment

1. Configure Testnet settings in `settings/Testnet.toml`
2. Deploy using Clarinet:
```bash
clarinet deployments apply --network=testnet
```

### Mainnet Deployment

1. Configure Mainnet settings in `settings/Mainnet.toml`
2. Deploy using Clarinet:
```bash
clarinet deployments apply --network=mainnet
```

## Security Notes

### Access Control

- **Contract Owner**: Can add/remove assessors and pause/resume contract
- **Authorized Assessors**: Can register officers, update scores, and modify officer status
- **Public Read Access**: All read-only functions are publicly accessible

### Security Features

1. **Role-based Authorization**: Only authorized assessors can modify officer data
2. **Emergency Pause**: Contract owner can pause all operations in emergencies
3. **Input Validation**: Score ranges (0-100) and data integrity checks
4. **Immutable Audit Trail**: All assessments are permanently recorded on-chain
5. **No Fund Handling**: Contract doesn't handle STX or other tokens, reducing financial risk

### Best Practices

- Regularly audit authorized assessor list
- Use emergency pause only when necessary
- Maintain detailed assessment reasons for transparency
- Monitor contract events for unusual activity
- Implement off-chain governance processes for assessor management

### Error Codes

- `u100`: Owner only operation
- `u101`: Officer not found
- `u102`: Invalid score (must be 0-100)
- `u103`: Officer already exists
- `u104`: Unauthorized assessor
- `u105`: Invalid address
- `u200`: Contract paused

## License

This project is licensed under the ISC License.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

For questions or support, please open an issue in the repository.