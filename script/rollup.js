const { ethers } = require("ethers");
require("dotenv").config();

console.log("Loaded environment variables:");
console.log("PRIVATE_KEY:", process.env.PRIVATE_KEY ? "Loaded ✅" : "❌ Not found");
console.log("RPC_URL:", process.env.RPC_URL);
console.log("ROLLUP_ADDRESS:", process.env.ROLLUP_ADDRESS);

const CONTRACT_ADDRESS = process.env.ROLLUP_ADDRESS;
const RPC_URL = process.env.RPC_URL;
const rawPrivateKey = process.env.PRIVATE_KEY;
console.log("Private key length:", rawPrivateKey.length);
// For debugging, print first 5 chars to check format
console.log("Private key starts with:", rawPrivateKey.substring(0, 5)); 

// Ensure proper format
let PRIVATE_KEY;
if (rawPrivateKey.startsWith('0x')) {
  PRIVATE_KEY = rawPrivateKey;
} else {
  PRIVATE_KEY = `0x${rawPrivateKey}`;
}

if (PRIVATE_KEY.length !== 66) {
  console.error(`Private key has incorrect length: ${PRIVATE_KEY.length}. Should be 66 chars including 0x prefix`);
  process.exit(1);
}



const ABI = [
    "function submitBatch(bytes32 _batchHash, bytes32 _stateData) external",
    "function approveBatch(uint256 batchId) external",
    "function challengeBatch(uint256 batchId) external payable",
    "function finalizeBatch(uint256 batchId) external",
    "function requiredApprovals() external view returns (uint256)",
    "function batches(uint256) external view returns (bytes32 hashdata, bytes32 stateData, uint256 timestamp, bool finalised)",
    "function isChallenged(uint256) external view returns (bool)"
  ];
  

const provider = new ethers.JsonRpcProvider(RPC_URL);
const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, wallet);

/** 
 * Submits a new rollup batch.
 */
async function submitBatch(batchHash, stateRoot) {
    
    console.log("Submitting batch...");
    const tx = await contract.submitBatch(batchHash, stateRoot);
    await tx.wait();
    console.log(`Batch submitted! TX Hash: ${tx.hash}`);
}

/**
 * Approves a batch if you're a validator.
 */

 async function approveBatch(batchId) {
        const isValidator = await contract.validators(wallet.address);
        if (!isValidator) {
            console.log("You are not a validator. Approval failed.");
            return;
        }
    
        console.log("Approving batch...");
        const tx = await contract.approveBatch(batchId);
        await tx.wait();
        console.log(`Batch approved! TX Hash: ${tx.hash}`);
    }

/**
 * Challenges a batch if fraudulent.
 */
async function challengeBatch(batchId) {
    console.log("Challenging batch...");
    const tx = await contract.challengeBatch(batchId, { value: ethers.parseEther("1.0") }); // 1 ETH bond required
    await tx.wait();
    console.log(`Batch challenged! TX Hash: ${tx.hash}`);
}

/**
 * Finalizes a batch if all conditions are met.
 */
async function finaliseBatch(batchId) {
    console.log("Checking batch status...");

    const [hashdata, stateData, submissionTime, finalised] = await contract.batches(batchId);
    const required = await contract.requiredApprovals();
    const batch = await contract.batches(batchId);
    const approvals = batch.approvals;
    
    const challenged = await contract.isChallenged(batchId);
    const currentTime = Math.floor(Date.now() / 1000);

    if (finalised) {
        console.log("Batch already finalized.");
        return;
    }
    if (challenged) {
        console.log("Batch has been challenged. Cannot finalize.");
        return;
    }
    if (currentTime < submissionTime + 7 * 24 * 60 * 60) {
        console.log("Challenge period still active. Cannot finalize yet.");
        return;
    }
    if (approvals < required) {
        console.log(`Not enough approvals yet. (${approvals}/${required})`);
        return;
    }

    console.log("Finalizing batch...");
    const tx = await contract.finaliseBatch(batchId);
    await tx.wait();
    console.log(`Batch finalized! TX Hash: ${tx.hash}`);
}


(async () => {
    const exampleBatchHash = ethers.keccak256(ethers.toUtf8Bytes("Example Batch Data"));
    const exampleStateRoot = ethers.keccak256(ethers.toUtf8Bytes("Example State Root"));

    await submitBatch(exampleBatchHash, exampleStateRoot);
})();
