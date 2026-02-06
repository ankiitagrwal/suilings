// Database type definitions for SBT credential tables
// Auto-generated types based on Supabase schema

export interface UserWallet {
  id: string;
  user_id: string;
  wallet_address: string;
  github_username: string | null;
  linked_at: string;
  is_primary: boolean;
  signature: string | null;
  message: string | null;
  created_at: string;
  updated_at: string;
}

export interface SBTCredential {
  id: string;
  user_id: string;
  wallet_address: string;
  sbt_object_id: string;
  github_username: string;
  completed_exercises: number;
  completion_date: string;
  streak_days: number;
  total_time_minutes: number | null;
  mint_transaction_digest: string;
  mint_status: 'pending' | 'confirmed' | 'failed';
  blockchain_network: 'mainnet' | 'testnet' | 'devnet' | 'localnet';
  metadata: CredentialMetadata | null;
  created_at: string;
  updated_at: string;
}

export interface CredentialMetadata {
  achievements?: string[];
  badges?: string[];
  categories_completed?: string[];
  fastest_solve_time?: number;
  total_hints_used?: number;
  perfect_streak?: number;
  [key: string]: any; // Allow additional properties
}

export interface CredentialStats {
  id: string;
  sbt_object_id: string;
  github_username: string;
  wallet_address: string;
  completed_exercises: number;
  completion_date: string;
  streak_days: number;
  mint_transaction_digest: string;
  blockchain_network: string;
  metadata: CredentialMetadata | null;
  created_at: string;
  days_since_completion: number | null;
  avatar_url: string | null;
  full_name: string | null;
}

// API Request/Response types
export interface LinkWalletRequest {
  wallet_address: string;
  signature: string;
  message: string;
}

export interface LinkWalletResponse {
  success: boolean;
  wallet: UserWallet;
  message?: string;
}

export interface CheckEligibilityResponse {
  eligible: boolean;
  completed_exercises: number;
  missing_exercises: number;
  total_exercises: number;
  has_wallet_linked: boolean;
  already_minted: boolean;
}

export interface MintCredentialRequest {
  wallet_address: string;
}

export interface MintCredentialResponse {
  success: boolean;
  credential?: SBTCredential;
  transaction_digest?: string;
  sbt_object_id?: string;
  explorer_url?: string;
  message?: string;
  error?: string;
}

export interface VerifyCredentialResponse {
  verified: boolean;
  credential?: CredentialStats;
  message?: string;
}

// Sui blockchain types
export interface SuiTransactionResult {
  digest: string;
  effects: {
    status: {
      status: 'success' | 'failure';
      error?: string;
    };
  };
  objectChanges?: Array<{
    type: string;
    objectId: string;
    objectType?: string;
  }>;
}

// Database insert types (without auto-generated fields)
export type InsertUserWallet = Omit<
  UserWallet,
  'id' | 'linked_at' | 'created_at' | 'updated_at'
>;

export type InsertSBTCredential = Omit<
  SBTCredential,
  'id' | 'created_at' | 'updated_at'
>;

// Database update types (all fields optional except where required)
export type UpdateUserWallet = Partial<Omit<UserWallet, 'id' | 'user_id'>>;

export type UpdateSBTCredential = Partial<
  Omit<SBTCredential, 'id' | 'user_id' | 'sbt_object_id'>
>;

