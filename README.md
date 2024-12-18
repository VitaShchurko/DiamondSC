# Diamond Contract with Facets

This project demonstrates the use of the **diamond pattern** for creating a modular and extendable smart contract in Solidity. Using the diamond pattern allows for building contracts where each component (facet) handles a specific functionality. This approach enables the easy upgrading and modification of a smart contract without the need to modify the core contract.

The project includes:
- A **Diamond contract**, which manages all facets.
- **Facets**: separate contracts that implement specific functionality (e.g., ownership management or data storage).
- **LibDiamondStorage**: a library for managing the contract's storage.
- **Deployment and testing scripts** using Hardhat.

## Project Files

1. **`Diamond.sol`**
   - This is the core contract responsible for managing facets. It allows adding, replacing, or removing functionality through the `diamondCut` function. The contract also has a fallback function to delegate calls to the appropriate facet.

2. **`LibDiamondStorage.sol`**
   - A library for managing contract storage. It provides access to `DiamondStorage`, which stores the addresses of facets and the contract owner. All owner management functions are executed through this library.

3. **`IDiamondCut.sol`**
   - This is the interface for the `Diamond.sol` contract, defining methods for performing operations on facets: adding, replacing, and removing functionality.

4. **`OwnershipFacet.sol`**
   - This contract implements ownership management functionality, including `transferOwnership` and checking the current owner. The `onlyOwner` modifier is used to restrict access to these functions.

5. **`StorageFacet.sol`**
   - A contract for storing data, where users can store and retrieve values associated with their address. Functions include `setData` and `getData`.

6. **`deploy.js`**
   - A deployment script for deploying the smart contracts on the Ethereum network using Hardhat. It deploys the core `Diamond` contract along with the two facets (`OwnershipFacet` and `StorageFacet`). After deployment, the facets are added to the diamond contract via the `diamondCut` function. The script also includes basic tests to verify the contract's functionality after deployment.

7. **Testing**
   - The deployment script also includes tests that check:
     - Correct setting of the contract's owner.
     - Functionality of ownership transfer.
     - Storing and retrieving data via `StorageFacet`.
     - Data isolation between users (ensuring one user cannot modify another user's data).

## To run this project locally, follow these steps:

### 1. **Install Dependencies**

```bash
yarn install
```

### 2. **Start Hardhat Node**

```bash
npx hardhat node
```

### 3. **Run the Tests**

```bash
npx hardhat run scripts/deploy.js --network localhost
```
and you will see:
<img width="758" alt="Знімок екрана 2024-12-19 о 00 18 24" src="https://github.com/user-attachments/assets/6b84ff66-76c8-4a1d-b05e-d86edbbfa15f" />

