# Treasury Vault

A Smart contract treasury management system built on Solidity for secure token operations with multisignature approval and decentralized claim distribution.

## Features

- **Treasury** - Manages token deposits, withdrawals, and balance tracking with secure transfers
- **TransactionProposal** - Multisig system requiring quorum consensus for executing treasury transactions
- **AccessRoles** - Interface-based role management for admins and signers with custom permissions
- **ClaimDistribution** - Merkle tree proof verification for distributing tokens to eligible users
- **DelayTime** - Time-lock mechanism enforcing minimum delays between proposal and execution

## Tech Stack

- **Solidity** ^0.8.13
- **Foundry** - Smart contract development
- **OpenZeppelin Contracts** - Security standards
- **Forge-std** - Testing utilities
