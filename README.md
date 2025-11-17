# Suilings

> **Practice Move on Sui — interactively, based on the Move Book.**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Rust](https://img.shields.io/badge/rust-stable-orange.svg)](https://www.rust-lang.org)
[![Sui](https://img.shields.io/badge/sui-main-green.svg)](https://github.com/MystenLabs/sui)
[![Move Book](https://img.shields.io/badge/based%20on-Move%20Book-indigo.svg)](https://move-book.com)

**Suilings** is an interactive practice platform for **Move** — the smart contract language used on the **Sui blockchain**.  
It provides hands-on exercises that complement the [Move Book](https://move-book.com), allowing you to practice what you learn.

## 📚 About Suilings

Suilings is designed as a **companion tool to the Move Book**. Instead of teaching Move from scratch, we provide:

- **Practice exercises** aligned with Move Book chapters
- **Direct links** to relevant Move Book sections
- **Real-time compilation** and testing
- **No separate educational content** - we point you to the Move Book for learning

### Learning Flow

1. **Read** the [Move Book](https://move-book.com) chapter
2. **Practice** with the corresponding Suilings exercise
3. **Master** Move programming through hands-on experience

---

## Features

- **Move Book Aligned**: Every exercise links to its Move Book chapter
- Interactive **watch mode** (`suilings watch`)
- **Build** or **test** exercises (`mode: build` or `test`)
- Real-time feedback with `sui move build` / `sui move test`
- `runner-crate` isolates exercises (no `Move.toml` in exercises)
- Clean, colorful UI with progress bar
- `r` = reset, `n` = next, `q` = quit

---

## Quick Install

```bash
git clone https://github.com/ankiitagrwal/suilings.git
cd suilings
./install.sh
```

The script installs:
- Rust + Cargo
- Sui CLI
- Suilings binary (`~/.cargo/bin/suilings`)

---

## Manual Install

1. **Clone**
    ```bash
    git clone https://github.com/ankiitagrwal/suilings.git
    cd suilings
    ```

2. **Install Rust (if needed)**
    ```bash
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    ```

3. **Install Sui CLI**
    ```bash
    curl -sSfL https://raw.githubusercontent.com/Mystenlabs/suiup/main/install.sh | sh
    ```

4. **Build & install Suilings**
    ```bash
    cargo install --path .
    ```

5. **Run**
    ```bash
    suilings watch
    ```

---

## Usage

```bash
suilings watch          # Start the interactive tutorial
suilings verify         # Verify the current exercise
suilings reset          # Reset the current exercise
suilings list           # List all exercises
suilings help           # Show help message
```

## Project Structure
```
suilings/
├── exercises/              ← Practice .move files (aligned with Move Book)
│   ├── intro/
│   │   └── hello_world.move (📚 move-book.com/guides/hello-world.html)
│   └── modules/
│       └── module_import.move (📚 move-book.com/guides/module.html)
├── runner-crate/           ← Shared Move.toml + helpers
├── info.toml               ← List of exercises with Move Book links
├── install.sh              ← One-click installer
└── src/                    ← Rust code
```

## Resources

- **📚 Move Book**: [move-book.com](https://move-book.com) - Start here to learn Move concepts
- **📖 Sui Docs**: [docs.sui.io](https://docs.sui.io) - Official Sui documentation
- **🎯 Suilings Web**: Practice exercises with Move Book integration
- **🔗 Exercise Mapping**: See `EXERCISE_MOVE_BOOK_MAPPING.md` for chapter references

## Contributing

We welcome contributions! When adding exercises:

1. **Follow the Move Book** code quality standards
2. **Link to Move Book chapters** - don't create separate educational content
3. **Reference official docs** for Sui-specific features
4. See `MOVE_BOOK_ALIGNMENT_PLAN.md` for detailed guidelines

## Acknowledgments

- Based on the [Move Book](https://move-book.com) by Damir Shamanaev
- Built for the [Sui](https://sui.io) blockchain
- Inspired by [Rustlings](https://github.com/rust-lang/rustlings)

## License

[MIT](LICENSE)

---

Made with ❤️ by the Suilings team.  
Built with Rust, Sui, and a love for learning.

