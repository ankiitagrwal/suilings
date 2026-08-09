/**
 * Platform admin check.
 * Set PLATFORM_ADMIN_EMAILS in .env as comma-separated emails.
 * Example: PLATFORM_ADMIN_EMAILS=ankit@example.com,co-founder@example.com
 */
export function isPlatformAdmin(userEmail: string | undefined): boolean {
  if (!userEmail) return false;
  const adminEmails = (process.env.PLATFORM_ADMIN_EMAILS || "")
    .split(",")
    .map((e) => e.trim().toLowerCase())
    .filter(Boolean);
  return adminEmails.includes(userEmail.toLowerCase());
}
