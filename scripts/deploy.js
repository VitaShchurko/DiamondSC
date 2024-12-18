const { ethers } = require("hardhat");
const chalk = require("chalk");

async function main() {
    console.log(chalk.blue("\n=== Deploying Diamond Contract ==="));

    const [deployer] = await ethers.getSigners();
    console.log(chalk.green(`Deploying contracts with account: ${deployer.address}`));

    const Diamond = await ethers.getContractFactory("Diamond");
    const diamond = await Diamond.deploy(deployer.address);
    await diamond.waitForDeployment();
    console.log(chalk.green(`Diamond deployed at: ${diamond.target}`));

    console.log(chalk.blue("\n=== Deploying Facets ==="));

    const OwnershipFacet = await ethers.getContractFactory("OwnershipFacet");
    const ownershipFacet = await OwnershipFacet.deploy();
    await ownershipFacet.waitForDeployment();
    console.log(chalk.green(`OwnershipFacet deployed at: ${ownershipFacet.target}`));

    const StorageFacet = await ethers.getContractFactory("StorageFacet");
    const storageFacet = await StorageFacet.deploy();
    await storageFacet.waitForDeployment();
    console.log(chalk.green(`StorageFacet deployed at: ${storageFacet.target}`));

    console.log(chalk.blue("\n=== Adding Facets to Diamond ==="));

    const diamondCut = [
        {
            facetAddress: ownershipFacet.target,
            action: 0,
            functionSelectors: [
                ownershipFacet.interface.getFunction("owner").selector,
                ownershipFacet.interface.getFunction("transferOwnership").selector,
            ],
        },
        {
            facetAddress: storageFacet.target,
            action: 0,
            functionSelectors: [
                storageFacet.interface.getFunction("setData").selector,
                storageFacet.interface.getFunction("getData").selector,
            ],
        },
    ];

    const tx = await diamond.diamondCut(diamondCut, ethers.ZeroAddress, "0x");
    await tx.wait();
    console.log(chalk.green("Facets added successfully!"));

    console.log(chalk.blue("\n=== Testing ==="));

    const diamondInterface = new ethers.Contract(diamond.target, [
        ...OwnershipFacet.interface.fragments,
        ...StorageFacet.interface.fragments,
    ], deployer);

    // Тест 1: Перевіряємо, що власник встановлений правильно
    const currentOwner = await diamondInterface.owner();
    console.log(chalk.green(`Diamond owner (initial): ${currentOwner}`));
    if (currentOwner !== deployer.address) {
        throw new Error("Owner was not correctly set during deployment!");
    }

    // Тест 2: Зміна власника
    const newOwner = ethers.Wallet.createRandom().address;
    console.log(chalk.yellow("\nTesting transferOwnership..."));
    console.log(`Attempting to transfer ownership to: ${newOwner}`);
    const transferTx = await diamondInterface.transferOwnership(newOwner);
    await transferTx.wait();

    const updatedOwner = await diamondInterface.owner();
    console.log(chalk.green(`Diamond owner (after transfer): ${updatedOwner}`));
    if (updatedOwner !== newOwner) {
        throw new Error("Ownership transfer failed!");
    }

    // Тест 3: Встановлення даних у StorageFacet
    console.log(chalk.yellow("\nTesting StorageFacet functions..."));
    const testData = 42;
    const setDataTx = await diamondInterface.setData(testData);
    await setDataTx.wait();

    const retrievedData = await diamondInterface.getData(deployer.address);
    console.log(chalk.green(`Stored data for deployer: ${retrievedData}`));
    if (retrievedData.toString() !== testData.toString()) {
        throw new Error("Stored data does not match expected value!");
    }

    // Тест 4: Дані іншого користувача
    const [, user] = await ethers.getSigners();
    console.log(chalk.yellow("\nTesting setData from another user..."));

    const userDiamondInterface = diamondInterface.connect(user);
    const userData = 100;
    const userSetDataTx = await userDiamondInterface.setData(userData);
    await userSetDataTx.wait();

    const userRetrievedData = await diamondInterface.getData(user.address);
    console.log(chalk.green(`Stored data for user: ${userRetrievedData}`));
    if (userRetrievedData.toString() !== userData.toString()) {
        throw new Error("User's stored data does not match expected value!");
    }

    // Перевірка ізоляції даних між користувачами
    console.log(chalk.yellow("\nEnsuring data isolation between users..."));
    const deployerData = await diamondInterface.getData(deployer.address);
    console.log(chalk.green(`Deployer's data after user's action: ${deployerData}`));
    if (deployerData.toString() !== testData.toString()) {
        throw new Error("Data isolation failed: deployer's data was modified!");
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
