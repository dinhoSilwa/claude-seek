#!/usr/bin/env bash

# This file is a wrapper that points to the actual claude-seek installed in user's home
# On first run, it will install the full claude-seek to ~/.claude-seek/

set -e

INSTALL_DIR="$HOME/.claude-seek"

# Check if already installed
if [ -f "$INSTALL_DIR/claude-seek" ]; then
    exec "$INSTALL_DIR/claude-seek" "$@"
fi

# First run - install
echo "🚀 First run detected. Installing claude-seek..."
echo ""

# Create directory
mkdir -p "$INSTALL_DIR"

# Copy the installer and run it
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$SCRIPT_DIR/../install-claude-seek.sh" "$INSTALL_DIR/"

cd "$INSTALL_DIR"
./install-claude-seek.sh

# Run the installed version
exec "$INSTALL_DIR/claude-seek" "$@"