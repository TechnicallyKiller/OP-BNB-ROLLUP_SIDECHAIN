require("dotenv").config();
const { ethers } = require("ethers");

// Load env vars
const {
  SEPOLIA_URL, RPC_URL, PRIVATE_KEY,
  L1_BRIDGE, L2_BRIDGE,
} = process.env;

// Providers & Wallets
const l1Provider = new ethers.JsonRpcProvider(SEPOLIA_URL);
const l2Provider = new ethers.JsonRpcProvider(RPC_URL);
const wallet = new ethers.Wallet(PRIVATE_KEY);

const l1Signer = wallet.connect(l1Provider);
const l2Signer = wallet.connect(l2Provider);

// ABIs
const l1BridgeAbi = [
  "event DepositIntiation(address sender, uint256 amount, uint nonce)",
  "function withdrawl_processed(bytes32) view returns (bool)",
  "function releaseOnL1(address user, uint256 amount, uint256 nonce) external"
];

const l2BridgeAbi = [
  "event WithdrawalInitiated(address user, uint256 amount, uint nonce)",
  "function MintonL2(address user, uint256 amount, uint nonce) external"
];

// Contracts
const l1Bridge = new ethers.Contract(L1_BRIDGE, l1BridgeAbi, l1Signer);
const l2Bridge = new ethers.Contract(L2_BRIDGE, l2BridgeAbi, l2Signer);

let lastL1Block, lastL2Block;

async function init() {
  lastL1Block = await l1Provider.getBlockNumber();
  lastL2Block = await l2Provider.getBlockNumber();
  console.log("Relayer started ✅");
  pollEvents(); // start polling loop
}

async function pollEvents() {
  try {
    // Poll L1 Deposits
    const currentL1 = await l1Provider.getBlockNumber();
    const l1Events = await l1Bridge.queryFilter("DepositIntiation", lastL1Block + 1, currentL1);
    for (const e of l1Events) {
      const { sender, amount, nonce } = e.args;
      console.log(`[L1 → L2] Deposit: ${sender}, Amount: ${amount}, Nonce: ${nonce}`);

      try {
        const tx = await l2Bridge.MintonL2(sender, amount, nonce);
        await tx.wait();
        console.log(`✅ Minted on L2`);
      } catch (err) {
        console.error("❌ Minting failed:", err.reason || err.message || err);
      }
    }
    lastL1Block = currentL1;
  } catch (err) {
    console.error("❌ Error polling L1:", err.message || err);
  }

  try {
    // Poll L2 Withdrawals
    const currentL2 = await l2Provider.getBlockNumber();
    const l2Events = await l2Bridge.queryFilter("WithdrawalInitiated", lastL2Block + 1, currentL2);
    for (const e of l2Events) {
      const { user, amount, nonce } = e.args;
      const id = ethers.keccak256(
        ethers.solidityPacked(["address", "uint256", "uint256"], [user, amount, nonce])
      );

      const already = await l1Bridge.withdrawl_processed(id);
      if (already) {
        console.log("⚠️ Already released on L1");
        continue;
      }

      try {
        const tx = await l1Bridge.releaseOnL1(user, amount, nonce);
        await tx.wait();
        console.log("✅ Released on L1");
      } catch (err) {
        console.error("❌ Release failed:", err.reason || err.message || err);
      }
    }
    lastL2Block = currentL2;
  } catch (err) {
    console.error("❌ Error polling L2:", err.message || err);
  }

  // 🔁 Repeat every 10 seconds
  setTimeout(pollEvents, 10_000);
}

init();
