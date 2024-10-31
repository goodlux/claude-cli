#!/bin/bash

# Installation paths
INSTALL_DIR="$HOME/.claude-cli"
BIN_PATH="$INSTALL_DIR/bin"
CONFIG_PATH="$INSTALL_DIR/config"

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

# Create installation directories
mkdir -p "$BIN_PATH" "$CONFIG_PATH"

# Copy main script
if [ -f "claude-cli.sh" ]; then
    cp claude-cli.sh "$BIN_PATH/claude-cli"
    chmod +x "$BIN_PATH/claude-cli"
else
    echo -e "${YELLOW}Warning: claude-cli.sh not found in current directory${NC}"
    # Download from GitHub if not present locally
    echo "Downloading claude-cli from repository..."
    curl -sSL -o "$BIN_PATH/claude-cli" "https://raw.githubusercontent.com/your-username/claude-cli/main/claude-cli.sh"
    chmod +x "$BIN_PATH/claude-cli"
fi

# Create config if it doesn't exist
if [ ! -f "$CONFIG_PATH/config.yml" ]; then
    cat > "$CONFIG_PATH/config.yml" << EOL
# Claude CLI Configuration
model: claude-3-sonnet
context_lines: 1000

# Safety settings
safety:
  confirm_destructive: true
  dry_run: false

# API settings
api:
  timeout: 30
  max_retries: 3
  endpoint: https://api.anthropic.com/v1/messages
EOL
fi

# Create credentials file if it doesn't exist
if [ ! -f "$CONFIG_PATH/credentials" ]; then
    cat > "$CONFIG_PATH/credentials" << EOL
# Anthropic API credentials
ANTHROPIC_API_KEY=your_api_key_here
EOL
    chmod 600 "$CONFIG_PATH/credentials"
fi

# Add to PATH in shell config if not already present
SHELL_CONFIG="$HOME/.bashrc"
if [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
fi

if ! grep -q "source $BIN_PATH/claude-cli" "$SHELL_CONFIG"; then
    echo "source $BIN_PATH/claude-cli" >> "$SHELL_CONFIG"
    echo -e "${GREEN}Added Claude CLI to $SHELL_CONFIG${NC}"
fi

echo -e "${GREEN}Installation complete!${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo "1. Edit $CONFIG_PATH/credentials with your Anthropic API key:"
echo "   nano $CONFIG_PATH/credentials"
echo "2. Reload your shell configuration:"
echo "   source $SHELL_CONFIG"
echo -e "${BLUE}Then you can use the following commands:${NC}"
echo "ccli 'your request'        # Short version"
echo "claude_cli 'your request'  # Full version"
echo -e "\n${YELLOW}Example: ccli 'list all PDF files modified this week'${NC}"

# Offer to open credentials file for editing
read -p "Would you like to edit your API credentials now? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v nano &> /dev/null; then
        nano "$CONFIG_PATH/credentials"
    else
        ${EDITOR:-vi} "$CONFIG_PATH/credentials"
    fi
fi
