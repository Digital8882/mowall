"use client";

import { useState } from "react";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useAccount, useContractRead, useContractWrite, usePrepareContractWrite } from "wagmi";
import { parseUnits } from "viem";

/**
 * Our deployed TokenWallet details
 *   - Replace with your deployed contract address
 */
const WALLET_ADDRESS = "0xYourDeployedSimpleTokenWallet";
const WALLET_ABI = [
  // Minimal ABI sections for deposit & withdraw
  {
    "inputs": [
      { "internalType": "address", "name": "token", "type": "address" },
      { "internalType": "uint256", "name": "amount", "type": "uint256" }
    ],
    "name": "deposit",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      { "internalType": "address", "name": "token", "type": "address" },
      { "internalType": "uint256", "name": "amount", "type": "uint256" }
    ],
    "name": "withdraw",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      { "internalType": "address", "name": "user", "type": "address" },
      { "internalType": "address", "name": "token", "type": "address" }
    ],
    "name": "balanceOf",
    "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
    "stateMutability": "view",
    "type": "function"
  }
];

export default function Home() {
  const { address, isConnected } = useAccount();

  const [tokenAddress, setTokenAddress] = useState("");
  const [amount, setAmount] = useState("");
  
  // Check user balanceOf in wallet
  const { data: userBalance } = useContractRead({
    address: WALLET_ADDRESS as `0x${string}`,
    abi: WALLET_ABI,
    functionName: "balanceOf",
    args: [address || "0x0000000000000000000000000000000000000000", tokenAddress || "0x0000000000000000000000000000000000000000"],
    watch: true,
    enabled: Boolean(isConnected && tokenAddress),
  });

  // Prepare deposit call
  const { config: depositConfig } = usePrepareContractWrite({
    address: WALLET_ADDRESS as `0x${string}`,
    abi: WALLET_ABI,
    functionName: "deposit",
    args: [tokenAddress, amount ? parseUnits(amount, 18) : 0n],
    enabled: Boolean(isConnected && tokenAddress && amount),
  });
  const { write: deposit } = useContractWrite(depositConfig);

  // Prepare withdraw call
  const { config: withdrawConfig } = usePrepareContractWrite({
    address: WALLET_ADDRESS as `0x${string}`,
    abi: WALLET_ABI,
    functionName: "withdraw",
    args: [tokenAddress, amount ? parseUnits(amount, 18) : 0n],
    enabled: Boolean(isConnected && tokenAddress && amount),
  });
  const { write: withdraw } = useContractWrite(withdrawConfig);

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-gradient-to-r from-slate-100 to-slate-300 text-slate-800 p-4">
      <ConnectButton />
      <h1 className="text-3xl font-bold mt-6 mb-4">Simple Token Wallet</h1>

      {!isConnected && <p>Please connect your wallet.</p>}

      {isConnected && (
        <div className="mt-4 w-full max-w-sm space-y-4 p-4 shadow-xl bg-white rounded-xl">
          <label className="block">
            <span className="text-gray-700 font-semibold">Token Address</span>
            <input
              type="text"
              placeholder="0x..."
              value={tokenAddress}
              onChange={e => setTokenAddress(e.target.value)}
              className="mt-1 block w-full rounded border-gray-300 p-2 border"
            />
          </label>

          <label className="block">
            <span className="text-gray-700 font-semibold">Amount</span>
            <input
              type="text"
              placeholder="0.0"
              value={amount}
              onChange={e => setAmount(e.target.value)}
              className="mt-1 block w-full rounded border-gray-300 p-2 border"
            />
          </label>

          <div className="flex gap-3">
            <button
              onClick={() => deposit?.()}
              disabled={!deposit}
              className="flex-1 bg-green-500 text-white py-2 rounded hover:bg-green-600 disabled:bg-gray-400"
            >
              Deposit
            </button>
            <button
              onClick={() => withdraw?.()}
              disabled={!withdraw}
              className="flex-1 bg-red-500 text-white py-2 rounded hover:bg-red-600 disabled:bg-gray-400"
            >
              Withdraw
            </button>
          </div>

          <div className="mt-3 p-2 bg-slate-50 rounded text-center">
            <p className="text-gray-600 text-sm">Your Wallet Balance (for token):</p>
            <p className="font-bold">{userBalance ? String(userBalance) : "0"}</p>
          </div>
        </div>
      )}
    </div>
  );
}
