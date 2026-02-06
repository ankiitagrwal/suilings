import type { Metadata } from "next";
import { Inter, JetBrains_Mono } from "next/font/google";
import "./globals.css";
import "@mysten/dapp-kit/dist/index.css";
import { Toaster } from "@/components/ui/sonner";
import { ThemeProvider } from "@/components/theme-provider";
import { WalletProvider } from "@/components/wallet/WalletProvider";

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin"],
});

const jetbrainsMono = JetBrains_Mono({
  variable: "--font-jetbrains-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Suilings - Learn Move on Sui",
  description: "Master smart contract development with interactive exercises. Learn Move programming for the Sui blockchain in your browser.",
  keywords: ["Move", "Sui", "blockchain", "smart contracts", "tutorial", "learning"],
  icons: {
    icon: [
      { url: '/favicon.svg', type: 'image/svg+xml' },
      { url: '/suilings-logo.svg', type: 'image/svg+xml' }
    ],
    apple: '/suilings-logo.svg',
  },
  openGraph: {
    title: "Suilings - Learn Move on Sui",
    description: "Master smart contract development with interactive exercises. 100% free, 82+ exercises, no setup required.",
    url: "https://suilings.com",
    siteName: "Suilings",
    images: [
      {
        url: '/og-image.svg',
        width: 1200,
        height: 630,
        alt: 'Suilings - Learn Move on Sui',
      },
    ],
    locale: 'en_US',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: "Suilings - Learn Move on Sui",
    description: "Master smart contract development with interactive exercises. 100% free, 82+ exercises, no setup required.",
    images: ['/og-image.svg'],
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body
        className={`${inter.variable} ${jetbrainsMono.variable} antialiased`}
      >
        <ThemeProvider
          attribute="class"
          defaultTheme="dark"
          enableSystem
          disableTransitionOnChange
        >
          <WalletProvider>
            {children}
            <Toaster richColors position="bottom-right" />
          </WalletProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
