# Introduction
This is a project which does the following:- 

- Creates and deployes smart contracts to Ethereum (can be first tested with Sepolia (an ethereum testnest or anvil local chain))
- Contracts facilitates the depositing as well as the withdrawal of funds
- Covers the basics of Solidity and developing contracts in Ethereum (Storage, Transactions, Tests)

Credits: Patrick Collins and the team! Thanks for the amazing course!

### Config
- Calling of private keys in Makefile is done by encrypting the private key and storing it in a keystore
- So, be sure to check that the keystore containing the intenden private key exists
- See, [Encrypting a private key](https://github.com/Cyfrin/foundry-full-course-f23?tab=readme-ov-file#can-you-encrypt-a-private-key---a-keystore-in-foundry-yet)


## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
