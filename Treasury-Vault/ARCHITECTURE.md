# Architecture

## System architecture

This is a decentralized, multi-signature treasury system that enables secure and governance-based control over transactions through collaboration between signers. This system implements multi-signature approval with timelocked execution, ensuring no single signer can independently execute transactions.
This project priotizes security, gas efficiency and role-based access control.

## Module Separation

### 1. AccessRoles Contract

This contract uses Openzeppelin `AccessControl` to manage role-based permissions

- **Default_Admin_Role**: Controls the system and can add new signers to the system.

- **Signers Role**: They are authorized to propose and confirm transactions.

- **quorum**: This is the minimum amount of signers required, before a transaction can be approved or executed.

- **totalSigners**: This is sum of all signers that are approved to execute a transaction in the system.

- **Function addCosigners**: This function can only be executed by the Default Admin Role and it is used to add cosigners to the system. It checks if an address already got the role and if not it grants the role to the address.

- **Function hasRole**: This returns a bool if the user has the hasRole. It is used in the interface so other contract can use the access control.

- **function getDefaultAdminRole**: This returns the hash of the default admin role.

- **Function getSignerRole**: This returns the hash of the signer role.

- **Function getQuorum**: This returns the quorum.

This contract prevents any single individual from controlling treasury assets and distributes authority across multiple trusted addresses.

## 2. TransactionaProposal Contract

This contract controls the multisignature workflow in the system. It manages the lifecycle of transaction proposals. The contract uses `ReentrancyGuard` to prevent reentrancy attacks during token transfer and transaction signing.

- **Proposal Fee**: This fee is set by the Default Admin. It is paid in ether to separate it from the treasury token. It helps reduce spamming.

- **Create Transaction**: Anyone can create a proposal by paying a proposal fee, this fee helps to reduce spamming.

- **Confirm Transaction**: Multiple signers must independently confirm a proposal, once the quorum is reached the transaction enters delay phase which is before execution.

- **Execute Transaction**: Once the delay time has passed and the quorum is reached for multiple signers the phase can commences and the proposal would be accepted and marked as executed 

- **Delay Phase**: There is a delay phase that is set by the Default Admin, it allows consensus to be reached over a transaction proposal before it can be executed or cancelled.

- **Cancel Transaction**: This function is to reject a proposal and a quorum must be reached before it can be cancelled and that is after the delay time must has passed.

### 3. Treasury Contract

This contract manages actual tokens reserves and balances 

- **DepositToken**: This functiona allows  users to depoit tokens.

- **Withdraw token**: This function allows users to withdraw tokens but not more than what was initially deposited.

- **WithdrawTokensForProposal**: This function can only be called by that contract address which is called in the TransactionProposal contract to send the value intended for proposal executed.

### 4. DelayTime Contract
This contract implenments the delay time in the transaction proposal.

- **setExecutionDelay**: This sets the executionduration time and can only be set be the default admin.


### Security Boundaries

- **Interace-Based Design**: All contracts interact through interfaces (`IERC20`, `IAccessRoles`, `IDelayTime`), preventing direct dependencies and limiting surface area for attacks. 

- **Proposal Fee**: Reduces transaction spamming by requiring proposers to pay a fee when creating proposals. 

- **Time-Locked Execution**: Combines quorum approval with enforced delays, creating a two-layer security model. 
1. Requires consensus across multiple signers.
2. Enforces a waiting period for execution

- **Reentrancy Protection**: All state-modifyying functions use `nonReentrant` to avoid reentrancy. 

This prevents flash-loan attacks and gives the community time to identify and respond to potentially malicious proposals.

