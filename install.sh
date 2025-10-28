#!/bin/bash

# Print colored output
print_colored() {
  GREEN='\033[0;32m'
  BLUE='\033[0;34m'
  RED='\033[0;31m'
  NC='\033[0m' # No Color

  echo -e "${!1}${2}${NC}"
}

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check OS
check_os() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "linux"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  else
    echo "unsupported"
  fi
}

# Install system dependencies
install_system_dependencies() {
  OS=$(check_os)
  if [ "$OS" = "linux" ]; then
    print_colored "BLUE" "Installing system dependencies for Linux..."
    sudo apt-get update
    sudo apt-get install -y build-essential curl wget git pkg-config
  elif [ "$OS" = "macos" ]; then
    print_colored "BLUE" "Installing system dependencies for macOS..."
    if ! command_exists brew; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install curl wget git pkg-config
  else
    print_colored "RED" "Unsupported operating system"
    exit 1
  fi
}

# Install Rust and Cargo
install_rust() {
  if command_exists rustc && command_exists cargo; then
    print_colored "GREEN" "Rust and Cargo are already installed"
    print_colored "BLUE" "Updating Rust..."
    rustup update
  else
    print_colored "BLUE" "Installing Rust and Cargo..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
  fi
}

# Install Sui CLI
install_sui() {
  if command_exists sui; then
    print_colored "GREEN" "Sui CLI is already installed"
    print_colored "BLUE" "Updating Sui CLI..."
    suiup
  else
    print_colored "BLUE" "Installing Sui CLI..."
    curl -sSfL https://raw.githubusercontent.com/Mystenlabs/suiup/main/install.sh | sh
    suiup
  fi
}

# Install suilings binary
install_suilings() {
  print_colored "BLUE" "Installing suilings..."
  cargo install --path .
  if command_exists suilings; then
    print_colored "GREEN" "suilings installed successfully"
  else
    print_colored "RED" "Failed to install suilings"
    exit 1
  fi
}

# Main installation process
main() {
  print_colored "BLUE" "Starting Suilings installation..."

  # Check and install system dependencies
  install_system_dependencies

  # Install Rust and Cargo
  install_rust

  # Install Sui CLI
  install_sui

  # Install suilings
  install_suilings

  # Final verification
  print_colored "BLUE" "Verifying installations..."

  # Verify Rust
  if command_exists rustc && command_exists cargo; then
    print_colored "GREEN" "Rust and Cargo are installed:"
    rustc --version
    cargo --version
  else
    print_colored "RED" "Rust installation failed"
    exit 1
  fi

  # Verify Sui
  if command_exists sui; then
    print_colored "GREEN" "Sui CLI is installed:"
    sui --version
  else
    print_colored "RED" "Sui installation failed"
    exit 1
  fi

  # Verify suilings
  if command_exists suilings; then
    print_colored "GREEN" "suilings is installed:"
    suilings --version
  else
    print_colored "RED" "suilings installation failed"
    exit 1
  fi

  print_colored "GREEN" "Installation completed successfully!"
  print_colored "BLUE" "Run 'suilings watch' to start learning Move on Sui!"
  print_colored "BLUE" "Tip: Restart your terminal or run 'source ~/.cargo/env' if commands are not found."
}

# Run main
main