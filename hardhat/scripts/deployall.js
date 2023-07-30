const { ethers } = require('ethers');
const fs = require('fs');

// Replace with your Ethereum wallet private key
const privateKey = 'YOUR_PRIVATE_KEY_GOES_HERE';

// Update with your Infura API key or Ethereum node URL
const provider = new ethers.providers.JsonRpcProvider('https://rinkeby.infura.io/v3/YOUR_INFURA_API_KEY');

// ABI and bytecode of the RWA contract
const rwaAbi = JSON.parse(fs.readFileSync('RWA_abi.json', 'utf8'));
const rwaBytecode = '0xYOUR_RWA_CONTRACT_BYTECODE';

async function deployRWAContract() {
  const wallet = new ethers.Wallet(privateKey, provider);

  // Deploy the contract
  const factory = new ethers.ContractFactory(rwaAbi, rwaBytecode, wallet);
  const rwaContract = await factory.deploy('Your RWA Name', [wallet.address]); // Add initial members' addresses here

  // Wait for the contract to be mined
  await rwaContract.deployed();

  // Display contract address and other info
  console.log('RWA Contract deployed to:', rwaContract.address);
  console.log('RWA Contract owner:', wallet.address);

  // Save contract address and ABI for later use
  saveContractData(rwaContract.address, rwaAbi);
}

function saveContractData(contractAddress, contractAbi) {
  const contractData = {
    address: contractAddress,
    abi: contractAbi
  };
  fs.writeFileSync('RWA_contract_data.json', JSON.stringify(contractData, null, 2));
  console.log('Contract data saved to RWA_contract_data.json');
}

deployRWAContract().catch((error) => {
  console.error('Error deploying contract:', error);
});
