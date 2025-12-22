dYouTube / Web3 Content Marketplace 🎥🎵✍️

A Web3-native content marketplace where creators publish videos, music, newsletters, and articles with true digital ownership, decentralized storage, and a time-based rent-to-own monetization model powered by USDC.

The platform combines on-chain pricing rules, off-chain payments, and firewall-protected access control to deliver a seamless Web2-like experience backed by Web3 trust guarantees.

🌐 Core Concept

Traditional platforms control content, pricing, and user access.

Our platform enables:

Decentralized content storage (IPFS / Filecoin / Walrus)

Trustless creator and pricing rules on-chain

Time-based rentals (user-defined number of days)

Pay-per-access using USDC

Rent-to-own ownership accumulation

Firewall-secured backend access checks

Wallet-based login (no accounts)

🚀 Key Features
👤 Creator Economy

On-chain creator registration

Immutable creator profiles

Support for multiple content formats:

🎥 Videos

🎵 Music

📰 Newsletters

✍️ Articles

📦 Decentralized Storage

Content stored on IPFS / Filecoin / Walrus

Smart contracts store only metadata URIs

No centralized content hosting

⏳ Time-Based Rental Model

Users choose how many days they want to rent content

Rental price = per-day price × number of days

Payments are made in USDC

Each rental grants access until expiration

Rentals contribute toward ownership

💰 Rent-to-Own with USDC

Every paid access increases a user’s total paid amount

When total payments ≥ full ownership price:

Content becomes permanently owned

No further rental payments required

Combines flexibility of rentals with permanence of ownership

💳 Payments (Off-Chain)

Payments handled off-chain using x402

USDC-only payments

No gas fees per view or rental

Fast, scalable transactions

🧠 Architecture Overview
🔗 On-Chain (Trust Layer)
1️⃣ CreatorRegistry

Registers creators

Stores creator profile metadata

Provides creator identity verification

2️⃣ CreatorHub

Stores content references and pricing rules:

Metadata URI

Free / paid flag

Per-day rental price

Full ownership price

Smart contracts define rules only, not access enforcement.

🔥 Off-Chain (Execution Layer)
🧾 Backend (Firewall-Protected)

Sits behind a firewall

Handles:

Rental duration tracking

Payment aggregation per content

Ownership determination

Access authorization

Prevents direct unauthorized content access

🔐 Access Control Flow

User requests content

Backend checks:

Is content free?

Is rental still active?

Is content already owned?

If payment required:

Triggers x402 USDC payment

If authorized:

Streams content from decentralized storage

🖥️ Frontend

Built with Next.js

Wallet-based authentication:

Privy

wagmi / viem

Users select rental duration

Streams content from IPFS/Filecoin/Walrus

UX similar to traditional platforms

🏗️ Tech Stack
Blockchain
Solidity
Ethereum / EVM-compatible chains
Hardhat
Storage
IPFS
Filecoin
Walrus
Payments
USDC
x402 (off-chain pay-per-access)
Frontend
Next.js
Privy
wagmi / viem
Backend
Firewall-protected service
Off-chain access control
Rental duration tracking

Ownership calculation
