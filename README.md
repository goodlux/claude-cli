# Claude CLI

A natural language interface for your terminal, powered by Claude. Convert English commands into bash commands using Claude's AI capabilities.

## Quick Install

One-line installation:
```bash
curl -sSL https://raw.githubusercontent.com/goodlux/claude-cli/main/install.sh | bash
```

After installation:
1. Edit `~/.claude-cli/credentials` and add your Anthropic API key
2. Start a new terminal or run: `source ~/.claude-cli/bin/claude-cli`

## Quick Uninstall

One-line uninstallation:
```bash
curl -sSL https://raw.githubusercontent.com/goodlux/claude-cli/main/uninstall.sh | bash
```

Or if you have the repository:
```bash
./uninstall.sh
```

After uninstalling, start a new terminal session or reload your shell configuration:
```bash
source ~/.bashrc  # or ~/.zshrc if using zsh
```

## Manual Installation

If you prefer to inspect everything first:

1. Clone the repository:
   ```bash
   git clone https://github.com/goodlux/claude-cli.git
   cd claude-cli
   ```

2. Run the installer:
   ```bash
   ./install.sh
   ```

3. Or install manually:
   ```bash
   # Create directories
   mkdir -p ~/.claude-cli/bin/lib ~/.claude-cli/cache
   
   # Copy files
   cp bin/claude-cli ~/.claude-cli/bin/
   cp bin/lib/* ~/.claude-cli/bin/lib/
   cp config/config.yml.example ~/.claude-cli/config.yml
   
   # Create credentials file
   echo "ANTHROPIC_API_KEY=your_api_key_here" > ~/.claude-cli/credentials
   
   # Set permissions
   chmod 755 ~/.claude-cli/bin/claude-cli ~/.claude-cli/bin/lib/*
   chmod 600 ~/.claude-cli/credentials
   chmod 644 ~/.claude-cli/config.yml
   
   # Add to shell config
   echo 'source ~/.claude-cli/bin/claude-cli' >> ~/.bashrc  # or ~/.zshrc
   ```

## Prerequisites

- `curl` and `jq` for API interactions
- `yq` for YAML configuration management
- An Anthropic API key from https://console.anthropic.com/

## Usage

Convert natural language to commands:
```bash
ccli "find all PDFs modified in the last week"
ccli "show me the largest files in this directory"
```

Manage settings:
```bash
# View all settings
claude_settings get

# Change a setting
claude_settings set model claude-3-sonnet-20240229

# Get help
claude_settings help
```
## Examples

Show system resource usage and most active processes:
```bash
ccli "show me CPU and memory usage, sorting processes by resource consumption"
```

Find and clean up large files:
```bash
ccli "find the 10 largest files in my home directory and show their sizes in human readable format"
```

Analyze code in current directory:
```bash
ccli "count lines of code by file extension in this directory, excluding node_modules"
```

Monitor system activity:
```bash
ccli "show me real-time network connections and their states"
```

Search and analyze logs:
```bash
ccli "find all error messages in today's log files and show their frequency"
```

## Features

- Natural language → bash command conversion
- System-aware context (knows your tools and OS)
- Command confirmation and editing
- Command history tracking
- Tab completion from history
- Settings management
- Configuration persistence

## Configuration

Edit `~/.claude-cli/config.yml` or use the `claude_settings` command to customize:
- Model selection
- Context lines
- Safety settings
- API configuration
- OS-specific settings

Example settings management:
```bash
# View current configuration
claude_settings get

# Change model
claude_settings set model claude-3-sonnet-20240229

# Adjust context lines
claude_settings set context_lines 500
```

## Troubleshooting

1. "API key not configured":
   ```bash
   edit ~/.claude-cli/credentials  # Add your API key
   ```

2. "Command not found":
   ```bash
   source ~/.bashrc  # or ~/.zshrc
   ```

3. Missing dependencies:
   ```bash
   # Ubuntu/Debian
   sudo apt-get install curl jq yq
   
   # macOS
   brew install curl jq yq
   ```

4. If uninstallation doesn't fully remove the command:
   - Start a new terminal session, or
   - Source your shell configuration:
     ```bash
     source ~/.bashrc  # or ~/.zshrc if using zsh
     ```

## Security Note

- Your API key is stored locally in `~/.claude-cli/credentials`
- The credentials file is created with restricted permissions (600)
- No data is stored outside your local machine
- All API calls are made directly to Anthropic's API

## Support

- Report issues: [GitHub Issues](https://github.com/goodlux/claude-cli/issues)
- API documentation: https://docs.anthropic.com/

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - feel free to use this in your own projects!