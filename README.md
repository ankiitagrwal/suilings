# Suilings

> **Learn Move on Sui — interactively, in your terminal.**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Rust](https://img.shields.io/badge/rust-stable-orange.svg)](https://www.rust-lang.org)
[![Sui](https://img.shields.io/badge/sui-main-green.svg)](https://github.com/MystenLabs/sui)

**Suilings** is an interactive tutorial for learning **Move** — the smart contract language used on the **Sui blockchain**.  
It guides you through **real `.move` files** with live feedback.

---

## Features

- Interactive **watch mode** (`suilings watch`)
- **Build** or **test** exercises (`mode: build` or `test`)
- Real-time feedback with `sui move build` / `sui move test`
- `// I AM NOT DONE` → blocks progress until removed
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
├── exercises/              ← Your .move files
│   ├── intro/
│   │   └── hello_world.move
│   └── modules/
│       └── module_import.move
├── runner-crate/           ← Shared Move.toml + helpers
├── info.toml               ← List of exercises
├── install.sh              ← One-click installer
└── src/                    ← Rust code
```

## License

[MIT](LICENSE)

---

Made with ❤️ by the Sui Community  
Built with Rust, Sui, and a love for learning.

