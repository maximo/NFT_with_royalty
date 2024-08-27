# Summary
This Solidity project builds 721 and 1155 NFTs modified to send royalty payments to the author whenever the NFT is
resold. I developed this smart contract. A modified version was used by a very well known NFT author.

# Configuration

## framework: brownie
documentation: https://eth-brownie.readthedocs.io/en/latest

### install brownie
#### option 1:
    > pip3 install eth-brownie

#### option 2:
Install pipx:
    > python3 -m pip install --user pipx
    > python3 -m pipx ensurepath

Install brownie
    > pipx install eth-brownie


## install ganache
    > sudo npm install -g ganache-cli

## install openzeppelin contracts
    > brownie pm install OpenZeppelin/openzeppelin-contracts@<VERSION>

    where:
        <VERSION> is currently at 4.0.0

# Compiling
To compile the solidity smart contracts, run the following command:
    > brownie compile

# Testing
To execute the unit tests defined in the tests/ folder, run the following command:
    > brownie test -s

The -s switch will print out to the console output from print() calls.

When calling a Solidity function, the returned result is the txn instead of the value. To get the value, add '.call()' to the end of the function name.
