# Suilings 🚀

> **Master Move Programming Through Practice — 82 Interactive Exercises from the Move Book**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Exercises](https://img.shields.io/badge/exercises-82-brightgreen.svg)](https://suilings.xyz)
[![Sui](https://img.shields.io/badge/sui-testnet-green.svg)](https://github.com/MystenLabs/sui)
[![Move Book](https://img.shields.io/badge/based%20on-Move%20Book-indigo.svg)](https://move-book.com)

**Suilings** is a comprehensive learning platform for **Move** on **Sui blockchain**. Practice with hands-on exercises, earn blockchain-verified credentials, compete on leaderboards, and join a growing community of Move developers.

## ✨ What Makes Suilings Special

🎓 **Learn by Doing**
- **curated exercises** covering basics to advanced Move concepts
- Real-time compilation and testing in your browser
- No installation required — start coding in seconds

🏆 **Earn Blockchain Credentials**
- Complete all exercises to earn a **Soulbound Token (SBT)**
- Verifiable on-chain proof of your Move programming skills
- Showcase your achievement on social media and GitHub

📚 **Move Book Aligned**
- Every exercise links to the corresponding Move Book chapter
- Learn the theory, then practice immediately
- No duplicate content — we point you to the best resources

🎮 **Gamified Learning**
- Track your progress with beautiful dashboards
- Compete on leaderboards (all-time, monthly, weekly)
- Earn achievements and build streaks
- Join a growing community of Move developers

🤖 **AI-Powered Help**
- Integrated AI assistant for contextual guidance
- Smart hints when you're stuck
- Learn at your own pace

---

## 🎯 Features

### Core Learning
- ✅ **Interactive Exercises** — From variables to advanced patterns
- ✅ **Real-Time Compilation** — Instant feedback with sui move build/test
- ✅ **Professional IDE** — Monaco editor with Move syntax highlighting
- ✅ **Contextual Hints** — Get help when you need it
- ✅ **Progress Tracking** — Never lose your place

### Gamification
- ✅ **Achievement System** — Unlock badges as you progress
- ✅ **Leaderboards** — See how you rank globally
- ✅ **Streak Tracking** — Build consistency, earn rewards
- ✅ **Stats Dashboard** — Comprehensive analytics

### Blockchain Integration
- ✅ **SBT Credentials** — Earn on-chain certificates
- ✅ **Wallet Integration** — Connect your Sui wallet
- ✅ **Public Verification** — Anyone can verify credentials
- ✅ **Credential Showcase** — Share your achievements

### Social
- ✅ **GitHub Authentication** — Quick social login
- ✅ **Community Leaderboard** — Compete with peers
- ✅ **AI Chat Assistant** — Get help anytime
- ✅ **Feedback System** — Help us improve

---

## 🚀 Quick Start

### Web Platform (Recommended)

1. **Visit** [suilings.xyz](https://suilings.xyz)
2. **Sign in** with GitHub
3. **Start coding** — No setup required!

### CLI Version

For the terminal-based interactive tutorial:

```bash
git clone https://github.com/ankiitagrwal/suilings.git
cd suilings
./install.sh
suilings watch
```

---

## 📖 Exercise Categories

| Category | Exercises | Topics |
|----------|-----------|--------|
| **Basics** | 15 | Variables, primitives, functions, control flow |
| **Structs & Types** | 12 | Structs, enums, generics, options |
| **Modules** | 8 | Module system, imports, visibility |
| **Objects** | 10 | Sui objects, ownership, storage, UID |
| **Advanced** | 15 | Capabilities, witness patterns, dynamic fields |
| **Collections** | 8 | Vectors, tables, bags, object collections |
| **Sui-Specific** | 14 | Events, publisher, receiving, tx_context, epoch |

**Total:** 82 exercises covering everything from "Hello World" to advanced Sui patterns

---

## 🏆 Earn Your Credential

Complete all exercises to earn a **Soulbound Token (SBT)** — a non-transferable NFT proving your Move programming mastery.

**What You Get:**
- ✅ On-chain certificate on Sui blockchain
- ✅ Public verification page
- ✅ Shareable badge for GitHub/LinkedIn
- ✅ Proof of skills for employers

**How It Works:**
1. Complete all exercises
2. Connect your Sui wallet
3. Mint your credential (free!)
4. Share your achievement


---

## 🛠️ Tech Stack

**Frontend:**
- Next.js 14 (App Router)
- TypeScript
- Tailwind CSS + shadcn/ui
- Monaco Editor
- @mysten/dapp-kit

**Backend:**
- Supabase (PostgreSQL + Auth)
- Docker (compilation service)
- Node.js

**Blockchain:**
- Sui Move smart contracts
- Soulbound Token (SBT) implementation

---

## 📂 Project Structure

```
suilings/
├── exercises/              # 82 Move practice exercises
│   ├── intro/
│   ├── primitives/
│   ├── functions/
│   ├── structs/
│   ├── modules/
│   ├── objects/
│   ├── ownership/
│   ├── generics/
│   ├── capabilities/
│   ├── witness/
│   ├── collections/
│   ├── events/
│   ├── dynamic_fields/
│   └── ... (18 categories total)
│
├── suilings-web/           # Web platform
│   ├── app/               # Next.js pages & API routes
│   ├── components/        # React components
│   ├── lib/              # Utilities & helpers
│   └── compilation-service/  # Docker-based compilation
│
├── contracts/             # Sui smart contracts
│   └── suilings_credential/  # SBT implementation
│
├── runner-crate/          # Shared Move.toml for CLI
├── src/                  # Rust CLI code
└── info.toml             # Exercise metadata

```

---

## 🎓 Learning Path

### For Beginners
1. **Read** the [Move Book](https://move-book.com) basics chapters
2. **Practice** with Suilings intro exercises
3. **Build** your first Move module
4. **Track** your progress on the dashboard

### For Intermediate Learners
1. **Master** advanced concepts (generics, capabilities, witness patterns)
2. **Complete** all 82 exercises
3. **Earn** your blockchain credential
4. **Compete** on the leaderboard

### For Advanced Developers
1. **Use** the platform to test snippets
2. **Help** others in the community
3. **Contribute** new exercises
4. **Showcase** your credential to employers

---

## 🌟 Community

- **Discord:** [Join our community](https://discord.gg/suilings) (coming soon)
- **Twitter/X:** [@Suilings](https://twitter.com/suiilings)
- **GitHub Discussions:** [Ask questions & share ideas](https://github.com/ankiitagrwal/suilings/discussions) (coming soon)

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### Add New Exercises
1. **Follow Move Book standards** — Don't create separate educational content
2. **Link to Move Book chapters** — Help learners find the theory
3. **Test thoroughly** — Ensure exercises build and tests pass
4. **Submit PR** — Include exercise metadata in `info.toml`

### Improve Existing Content
- Fix bugs in exercises
- Improve hints and descriptions
- Add better test cases
- Enhance error messages

### Report Issues
- Found a bug? [Open an issue](https://github.com/ankiitagrwal/suilings/issues)
- Have a suggestion? [Start a discussion](https://github.com/ankiitagrwal/suilings/discussions)

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## 📚 Resources

- **🌐 Suilings Platform**: [suilings.xyz](https://suilings.xyz)
- **📖 Move Book**: [move-book.com](https://move-book.com) — Learn Move concepts
- **📘 Sui Docs**: [docs.sui.io](https://docs.sui.io) — Official documentation
- **🔗 GitHub**: [github.com/ankiitagrwal/suilings](https://github.com/ankiitagrwal/suilings)

---

## 🙏 Acknowledgments

- **[Move Book](https://move-book.com)** by Damir Shamanaev — The foundation of Move education
- **[Sui](https://sui.io)** — The blockchain platform powering Suilings
- **[Rustlings](https://github.com/rust-lang/rustlings)** — Inspiration for the CLI tutorial format
- **Our community** — Thank you for learning, contributing, and sharing!

---

## 📄 License

[MIT License](LICENSE) — Free to use, modify, and distribute.

---

## 🚀 Ready to Start?

Visit **[suilings.xyz](https://suilings.xyz)** and begin your Move programming journey today!

Or try the CLI version:
```bash
git clone https://github.com/ankiitagrwal/suilings.git
cd suilings
./install.sh
suilings watch
```

---

<div align="center">

**Made with ❤️ by the Suilings team**

[Website](https://suilings.xyz) • [GitHub](https://github.com/ankiitagrwal/suilings) • [Discord](https://discord.gg/suilings) • [Twitter](https://twitter.com/suilings)

⭐ Star us on GitHub if you find Suilings helpful!

</div>
