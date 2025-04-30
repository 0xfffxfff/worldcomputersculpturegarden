# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build/Test Commands
- Compile contracts: `npx hardhat compile`
- Run all tests: `npx hardhat test`
- Run single test: `npx hardhat test contracts/test/garden.test.ts`
- Run specific test: `npx hardhat test contracts/test/garden.test.ts --grep "Deployment"`
- Deploy contracts: `npx hardhat deploy --network <network>`
- Check contract size: `REPORT_SIZE=true npx hardhat compile`
- Run gas reporter: `REPORT_GAS=true npx hardhat test`

## Code Style Guidelines
- TypeScript with strict type checking
- Use ES2020 features with CommonJS modules
- Import order: external modules first, then project imports
- Solidity version: 0.8.28
- Function/variable naming: camelCase
- Contract naming: PascalCase
- Use ethers.js v5+ for contract interactions
- Use async/await pattern (not promise chains)
- Proper error handling with try/catch or reverts
- Follow hardhat-deploy patterns for deployment scripts
- Format contract addresses with ethers.getAddress() for checksum validation