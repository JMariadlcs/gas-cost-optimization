# gas-cost-optimization

This repository serves as a demonstration of optimizing the Distribute function within the [Distribute](https://github.com/JMariadlcs/gas-cost-optimization/blob/main/original/Distribute.sol) smart contract. We are comparing the [original](https://github.com/JMariadlcs/gas-cost-optimization/blob/main/original/Distribute.sol) and [optimized](https://github.com/JMariadlcs/gas-cost-optimization/blob/main/optimized/Distribute.sol) versions of the Distribute smart contract.

## Optimizations

- First optimization: The initial implemented alteration pertains to the `require` statement, which has been substituted with an `if + revert` statement. This modification significantly reduces gas consumption compared to the previous require statement when the tx reverts.

    1. Original:
    ```solidity
        require(
            block.timestamp > createTime + 2 weeks,
            "cannot call distribute yet"
        );
    ```

    2. Optimized:
    ```solidity
        if (block.timestamp <= createTime + 2 weeks) revert();
    ```

- Second optimization: To comprehend the second optimization method employed, it is assumed that the deployer is sending ether to the contract in the deployment tx, we are testing it using 6 ethers:

The Distribute contract is deployed, and ether is transmitted during deployment through the constructor (the constructor incorporates the 'payable' keyword to allow ether reception):
In this scenario, there is a much better optimization that will save more gas as the Smart Contract retains ether but the `distribute` function consistently reverts. This occurs because the function attempts to dispatch an amount of ether that exceeds the contract's balance. The issue arises from the calculation of `amount`, defined as `uint256 amount = address(this).balance / 4`, followed by six transfers of this amount. Consequently, the function attempts to transfer a cumulative amount that surpasses the quantity of ether held by the contract.

As the goal is to optmize the smart contract and not to fix the reverting scenario, a more efficient strategy involves incorporating an `if + revert` statement. This statement verifies whether the subsequent ether transfers are destined to revert. If the transfers are expected to revert, the smart contract promptly executes a revert without proceeding with the ether transfers. As a result, despite yielding the same outcome of a revert, this method significantly reduces gas consumption. This `if + revert` statement should be the first operation on the function so that the execution does not consume more gas checking or calculating other instructions for then reverting due to the `if + revert` statement.

Statement added:

```solidity
 if (amount * 6 > address(this).balance) revert();
```



## Performance measurements

To contrast the alterations in gas terms, the contracts were deployed using the REMIX IDE, yielding the following results:

- First optimization (the testing of the first optimization has been done without having the second implementation implemented): 

    The transaction reverts due to a require statement because it has not elapsed the two-week period:

        |           | Tx cost   | Execution cost |
        | Original  | 23835 gas | 2771 gas       |
        | Optimized | 23542 gas | 2478 gas       |

- Second optimization:

    The contract was deployed sending 6 ethers and the `distribute` tx reverts:

        |           | Tx cost   | Execution cost |
        | Original  | 71395 gas | 50331 gas      |
        | Optimized | 21658 gas | 594 gas       |