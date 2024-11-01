#!/bin/bash
# bin/lib/shell.sh - Shell configuration and utilities

# Detect shell environment and set configuration
detect_shell_config() {
    local shell_path="$1"
    
    case "$shell_path" in
        */zsh)
            if [ -f "$HOME/.zshrc" ]; then
                echo "$HOME/.zshrc"
            elif [ -f "$HOME/.zprofile" ]; then
                echo "$HOME/.zprofile"
            else
                echo "$HOME/.zshrc"
                touch "$HOME/.zshrc"
            fi
            ;;
        */bash)
            if [ -f "$HOME/.bashrc" ]; then
                echo "$HOME/.bashrc"
            elif [ -f "$HOME/.bash_profile" ]; then
                echo "$HOME/.bash_profile"
            else
                echo "$HOME/.bashrc"
                touch "$HOME/.bashrc"
            fi
            ;;
        *)
            return 1
            ;;
    esac
}

# Setup shell configuration
setup_shell_config() {
    local install_dir="$1"
    local shell_config
    
    shell_config=$(detect_shell_config "$SHELL")
    if [ $? -ne 0 ]; then
        error "Unsupported shell: $SHELL"
        echo "Claude CLI supports bash and zsh."
        echo "For Windows users, please use WSL or Git Bash."
        return 1
    fi

    # Backup config file
    cp "$shell_config" "${shell_config}.bak"

    # Add source line if not present
    if ! grep -q "source.*$install_dir/bin/claude-cli" "$shell_config"; then
        [ -s "$shell_config" ] && echo >> "$shell_config"
        echo "# Added by Claude CLI installer" >> "$shell_config"
        echo "source $install_dir/bin/claude-cli" >> "$shell_config"
        return 0
    fi
    return 2  # Already configured
}

# Check for OS-specific requirements
check_os_requirements() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local missing_utils=()
        for util in gdate gsed gawk; do
            if ! command -v "$util" >/dev/null 2>&1; then
                missing_utils+=("$util")
            fi
        done
        
        if [ ${#missing_utils[@]} -ne 0 ]; then
            echo "MacOS detected. For full functionality, consider installing GNU utilities:"
            echo "brew install coreutils gnu-sed gawk"
            return 1
        fi
    fi
    return 0
}

# Remove shell configuration
remove_shell_config() {
    local configs=("$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.zshrc" "$HOME/.zprofile")
    
    for config in "${configs[@]}"; do
        if [ -f "$config" ]; then
            # Create backup
            cp "$config" "${config}.bak.$(date +%Y%m%d)"
            # Remove Claude CLI lines
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' '/claude-cli/d' "$config"
            else
                sed -i '/claude-cli/d' "$config"
            fi
        fi
    done
}

# Get OS-specific commands
get_os_commands() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "date_cmd=gdate"
        echo "sed_cmd=gsed"
        echo "awk_cmd=gawk"
    else
        echo "date_cmd=date"
        echo "sed_cmd=sed"
        echo "awk_cmd=awk"
    fi
}