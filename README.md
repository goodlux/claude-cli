# Claude CLI Installation Guide

A natural language interface for your terminal, powered by Claude.

## One-Line Quick Install
```bash
mkdir -p ~/.claude-cli && curl -o ~/.claude-cli/claude-cli.sh https://raw.githubusercontent.com/your-repo/claude-cli/main/claude-cli.sh && echo 'source ~/.claude-cli/claude-cli.sh' >> ~/.bashrc && source ~/.bashrc
```

## Manual Installation

### 1. Prerequisites
- `curl` and `jq` installed
- An Anthropic API key from https://console.anthropic.com/

### 2. Setup Steps
```bash
# Create directory
mkdir -p ~/.claude-cli

# Create and edit the credentials file
cat > ~/.claude-cli/credentials << EOL
# Anthropic API credentials
ANTHROPIC_API_KEY=your_api_key_here
EOL

# Set proper permissions
chmod 600 ~/.claude-cli/credentials

# Add to your shell config
echo 'source ~/.claude-cli/claude-cli.sh' >> ~/.bashrc  # or ~/.zshrc for Zsh
source ~/.bashrc  # or source ~/.zshrc
```

## Usage

You can use the CLI in two ways:
```bash
ccli "your natural language request"        # Short version
claude_cli "your natural language request"  # Full version
```

### Examples
```bash
ccli "find all PDFs modified this week"
ccli "show me the largest files in this folder"
ccli "compress all images in current directory"
```

### Features
- Natural language → bash command conversion
- Safety confirmation before execution
- Option to edit suggested commands
- Command history tracking
- Git-aware context
- Tab completion from history

### Tips
- Be specific in your requests
- Use quotes around your request to handle spaces
- The tool provides context about your current directory and git status
- Type `e` at the confirmation prompt to edit the suggested command

### Command Options
- `y` - Execute the command
- `n` - Cancel execution
- `e` - Edit the command before execution

## Troubleshooting

### Common Issues
1. "API key not configured":
   ```bash
   nano ~/.claude-cli/credentials
   # Replace your_api_key_here with actual key
   ```

2. "Command not found":
   ```bash
   source ~/.bashrc  # Reload shell config
   ```

3. "jq not found":
   ```bash
   # Ubuntu/Debian
   sudo apt-get install jq
   
   # macOS
   brew install jq
   ```

### Updating
To update the CLI, simply replace the script file and reload:
```bash
# Replace claude-cli.sh with new version
source ~/.claude-cli/claude-cli.sh
```

### Uninstalling
```bash
rm -rf ~/.claude-cli
# Remove the source line from ~/.bashrc or ~/.zshrc
```

## Configuration
Edit `~/.claude-cli/config.yml` to customize:
- Model selection
- Context lines
- Safety settings
- API timeout

## Support
- Report issues: [GitHub Issues](https://github.com/your-repo/claude-cli/issues)
- API documentation: https://docs.anthropic.com/