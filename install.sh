#!/bin/bash

# Installation paths
USER_CONFIG_DIR="$HOME/.claude-cli"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Installing Claude CLI...${NC}"

# Check for required dependencies
for cmd in curl jq; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${YELLOW}Warning: $cmd is not installed. Please install it for full functionality.${NC}"
    fi
done

# Create user config directory
mkdir -p "$USER_CONFIG_DIR"

# Create user config from template
if [ ! -f "$USER_CONFIG_DIR/config.yml" ]; then
    if [ -f "$REPO_DIR/config/config.yml.example" ]; then
        cp "$REPO_DIR/config/config.yml.example" "$USER_CONFIG_DIR/config.yml"
    else
        echo -e "${YELLOW}Warning: config template not found, creating default config${NC}"
        cat > "$USER_CONFIG_DIR/config.yml" << EOL
# Claude CLI Configuration
model: claude-3-sonnet-20240229
context_lines: 1000

# Safety settings
safety:
  confirm_destructive: true
  dry_run: false

# API settings
api:
  timeout: 30
  max_retries: 3
EOL
    fi
fi

# Create credentials file if it doesn't exist
if [ ! -f "$USER_CONFIG_DIR/credentials" ]; then
    cat > "$USER_CONFIG_DIR/credentials" << EOL
# Anthropic API credentials
ANTHROPIC_API_KEY=your_api_key_here
EOL
    chmod 600 "$USER_CONFIG_DIR/credentials"
fi

# Create history file
touch "$USER_CONFIG_DIR/history.txt"

# Set proper permissions
chmod 700 "$USER_CONFIG_DIR"
chmod 600 "$USER_CONFIG_DIR/config.yml"
chmod 600 "$USER_CONFIG_DIR/history.txt"

# Add to shell config if not already present
SHELL_CONFIG="$HOME/.bashrc"
if [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
fi

SCRIPT_PATH="$REPO_DIR/bin/claude-cli"
if ! grep -q "source.*claude-cli" "$SHELL_CONFIG"; then
    echo "source $SCRIPT_PATH" >> "$SHELL_CONFIG"
    echo -e "${GREEN}Added Claude CLI to $SHELL_CONFIG${NC}"
fi

echo -e "${GREEN}Installation complete!${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo "1. Edit $USER_CONFIG_DIR/credentials with your Anthropic API key:"
echo "   nano $USER_CONFIG_DIR/credentials"
echo "2. Reload your shell configuration:"
echo "   source $SHELL_CONFIG"

echo -e "${BLUE}You can then use:${NC}"
echo "ccli 'your request'        # Short version"
echo "claude_cli 'your request'  # Full version"

# Offer to edit credentials
read -p "Would you like to edit your API credentials now? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v nano &> /dev/null; then
        nano "$USER_CONFIG_DIR/credentials"
    else
        ${EDITOR:-vi} "$USER_CONFIG_DIR/credentials"
    fi
fi
