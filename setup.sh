#!/bin/bash
# Setup script for AstroNvim config
# Run this after cloning to a new machine: bash ~/.config/nvim/setup.sh

set -e

NVIM_CONFIG="$HOME/.config/nvim"

echo "Setting up AstroNvim config..."

# Make nvim-edit executable
chmod +x "$NVIM_CONFIG/scripts/nvim-edit"
echo "✓ Made nvim-edit executable"

# Symlink lazygit config to the correct platform-specific location
if [[ "$OSTYPE" == "darwin"* ]]; then
  LAZYGIT_CONFIG_DIR="$HOME/Library/Application Support/lazygit"
else
  # Linux: respect XDG_CONFIG_HOME, fall back to ~/.config
  LAZYGIT_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/lazygit"
fi

mkdir -p "$LAZYGIT_CONFIG_DIR"

LAZYGIT_CONFIG="$LAZYGIT_CONFIG_DIR/config.yml"

if [ -L "$LAZYGIT_CONFIG" ]; then
  rm "$LAZYGIT_CONFIG"
elif [ -f "$LAZYGIT_CONFIG" ]; then
  cp "$LAZYGIT_CONFIG" "$LAZYGIT_CONFIG.bak"
  echo "  Backed up existing lazygit config to $LAZYGIT_CONFIG.bak"
  rm "$LAZYGIT_CONFIG"
fi

ln -s "$NVIM_CONFIG/lazygit/config.yml" "$LAZYGIT_CONFIG"
echo "✓ Linked lazygit config: $LAZYGIT_CONFIG -> $NVIM_CONFIG/lazygit/config.yml"

echo ""
echo "Done! Restart Neovim for changes to take effect."
