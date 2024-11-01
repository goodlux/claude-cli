#!/bin/bash
# Uninstall script for Claude CLI

# Print colorized status messages
info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }
success() { echo -e "\033[0;32m[SUCCESS]\033[0m $1"; }

info "Uninstalling Claude CLI..."

# Remove the installation directory
rm -rf ~/.claude-cli
info "Removed installation directory"

# Remove source lines from common shell config files
for config_file in ~/.bashrc ~/.bash_profile ~/.zshrc ~/.zprofile; do
    if [ -f "$config_file" ]; then
        # Create backup first
        cp "$config_file" "${config_file}.bak"
        # Remove any lines containing claude-cli
        sed -i.bak '/claude-cli/d' "$config_file"
    fi
done
info "Removed source lines from shell config files"

# Clean up current session
for alias in ccli claude_cli; do
    unalias $alias 2>/dev/null
done

for func in claude_cli _claude_cli_complete claude_settings _claude_settings_complete; do
    unset -f $func 2>/dev/null
done

for var in CLAUDE_CLI_MODEL CLAUDE_CLI_CONTEXT_LINES ANTHROPIC_API_KEY \
          CLAUDE_CLI_CONFIG_DIR CLAUDE_CLI_HISTORY CLAUDE_CLI_CONFIG; do
    unset $var 2>/dev/null
done
info "Cleaned up current session"

# Remove completion
for cmd in claude_cli ccli claude_settings; do
    complete -r $cmd 2>/dev/null
done
info "Removed command completions"

# Clear any cached completions
hash -r 2>/dev/null
info "Cleared command hash table"

success "Claude CLI has been uninstalled"
echo
echo "Please start a new terminal session for changes to take full effect."
echo "Alternatively, you can run: exec $SHELL -l"