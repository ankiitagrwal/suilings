import { SuiClient, SuiHTTPTransport } from "@mysten/sui/client";
import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";
import { fromBase64 } from "@mysten/sui/utils";

// Network configuration
export const SUI_NETWORKS = {
  localnet: "http://localhost:9000",
  devnet: "https://fullnode.devnet.sui.io:443",
  testnet: "https://fullnode.testnet.sui.io:443",
  mainnet: "https://fullnode.mainnet.sui.io:443",
} as const;

export type SuiNetwork = keyof typeof SUI_NETWORKS;

/**
 * Get Sui client for the configured network
 */
export function getSuiClient(network?: SuiNetwork): SuiClient {
  const networkName = (network || process.env.SUI_NETWORK || "testnet") as SuiNetwork;
  const rpcUrl = process.env.SUI_RPC_URL || SUI_NETWORKS[networkName];

  return new SuiClient({
    transport: new SuiHTTPTransport({
      url: rpcUrl,
    }),
  });
}

/**
 * Get admin keypair from environment variable
 */
export function getAdminKeypair(): Ed25519Keypair {
  const privateKey = process.env.ADMIN_WALLET_PRIVATE_KEY;

  if (!privateKey) {
    throw new Error("ADMIN_WALLET_PRIVATE_KEY not configured");
  }

  try {
    return Ed25519Keypair.fromSecretKey(fromBase64(privateKey));
  } catch (error) {
    throw new Error("Invalid admin wallet private key format");
  }
}

/**
 * Get contract configuration from environment
 */
export function getContractConfig() {
  const packageId = process.env.CREDENTIAL_PACKAGE_ID;
  const adminCapId = process.env.CREDENTIAL_ADMIN_CAP_ID;
  const registryId = process.env.CREDENTIAL_REGISTRY_ID;

  if (!packageId || !adminCapId || !registryId) {
    throw new Error("Contract configuration incomplete. Please deploy the contract and set environment variables.");
  }

  return {
    packageId,
    adminCapId,
    registryId,
  };
}

/**
 * Get explorer URL for an object or transaction
 */
export function getExplorerUrl(
  type: "object" | "transaction",
  id: string,
  network?: SuiNetwork
): string {
  const networkName = network || (process.env.SUI_NETWORK as SuiNetwork) || "testnet";
  
  const baseUrls: Record<SuiNetwork, string> = {
    mainnet: "https://suivision.xyz",
    testnet: "https://testnet.suivision.xyz",
    devnet: "https://devnet.suivision.xyz",
    localnet: "http://localhost:3000",
  };

  const baseUrl = baseUrls[networkName];
  const path = type === "object" ? "object" : "txblock";

  return `${baseUrl}/${path}/${id}`;
}

/**
 * Format Sui address for display
 */
export function formatAddress(address: string, length: number = 6): string {
  if (!address) return "";
  if (address.length <= length * 2) return address;
  return `${address.slice(0, length)}...${address.slice(-length)}`;
}

/**
 * Validate Sui address format
 */
export function isValidSuiAddress(address: string): boolean {
  return /^0x[a-fA-F0-9]{64}$/.test(address);
}

