#!/bin/bash
set -e

# Debug mode - needs to be set before any function definitions
if [ -n "$DEBUG" ] || [ "$1" = "--debug" ]; then
    DEBUG=true
else
    DEBUG=false
fi

# Configuration
INSTALL_DIR="$HOME/.claude-cli"
REPO_URL="https://raw.githubusercontent.com/goodlux/claude-cli/main"
SCRIPT_FILES=("bin/claude-cli" "bin/lib/context.sh" "bin/lib/settings.sh" "bin/lib/shell.sh")
CONFIG_FILE="config/config.yml.example"

# Basic utility functions - these need to be defined first
debug() {
    if [ "$DEBUG" = "true" ]; then
        echo -e "\033[0;35m[DEBUG]\033[0m $1" >&2
    fi
}

info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }
success() { echo -e "\033[0;32m[SUCCESS]\033[0m $1"; }
error() { echo -e "\033[0;31m[ERROR]\033[0m $1" >&2; }

# Now check if running from curl pipe or local repo
if [ -t 0 ] && [ -f "./bin/claude-cli" ]; then
    USE_LOCAL=true
    debug "Running from local repository"
else
    USE_LOCAL=false
    debug "Running from remote installation"
fi

# Install files from either local or remote source
install_files() {
    if [ "$USE_LOCAL" = true ]; then
        info "Installing from local files..."
        
        for file in "${SCRIPT_FILES[@]}"; do
            info "Copying $file"
            local dir=$(dirname "$INSTALL_DIR/$file")
            mkdir -p "$dir"
            if [ -f "./$file" ]; then
                cp "./$file" "$INSTALL_DIR/$file"
                chmod 755 "$INSTALL_DIR/$file"
                success "Copied $file"
            else
                error "Missing local file: ./$file"
                exit 1
            fi
        done
        
        if [ ! -f "$INSTALL_DIR/config.yml" ]; then
            info "Copying config file"
            cp "./$CONFIG_FILE" "$INSTALL_DIR/config.yml"
            chmod 644 "$INSTALL_DIR/config.yml"
            success "Copied config.yml"
        fi
    else
        info "Downloading from repository..."
        
        for file in "${SCRIPT_FILES[@]}"; do
            info "Downloading $file"
            local dir=$(dirname "$INSTALL_DIR/$file")
            local url="$REPO_URL/$file"
            mkdir -p "$dir"
            
            if curl --output /dev/null --silent --head --fail "$url"; then
                if ! curl -sSL "$url" -o "$INSTALL_DIR/$file"; then
                    error "Failed to download $file"
                    exit 1
                fi
                chmod 755 "$INSTALL_DIR/$file"
                success "Downloaded $file"
            else
                error "File not found at URL: $url"
                exit 1
            fi
        done
        
        if [ ! -f "$INSTALL_DIR/config.yml" ]; then
            info "Downloading config file"
            local config_url="$REPO_URL/$CONFIG_FILE"
            if curl --output /dev/null --silent --head --fail "$config_url"; then
                if ! curl -sSL "$config_url" -o "$INSTALL_DIR/config.yml"; then
                    error "Failed to download config file"
                    exit 1
                fi
                chmod 644 "$INSTALL_DIR/config.yml"
                success "Downloaded config.yml"
            else
                error "Config file not found at URL: $config_url"
                exit 1
            fi
        fi
    fi
}

# Configure shell
configure_shell() {
    debug "Configuring shell..."
    local shell_config
    
    case "$SHELL" in
        */zsh) shell_config="$HOME/.zshrc" ;;
        */bash) shell_config="$HOME/.bashrc" ;;
        *) 
            error "Unsupported shell: $SHELL"
            echo "Please manually add: source $INSTALL_DIR/bin/claude-cli"
            return 1
            ;;
    esac
    
    debug "Using shell config: $shell_config"
    
    if ! grep -q "source.*$INSTALL_DIR/bin/claude-cli" "$shell_config"; then
        echo "source $INSTALL_DIR/bin/claude-cli" >> "$shell_config"
        success "Added Claude CLI to $shell_config"
    else
        info "Claude CLI already configured in $shell_config"
    fi
}

# Verify installation
verify_installation() {
    debug "Verifying installation..."
    
    local missing_files=0
    for file in "${SCRIPT_FILES[@]}"; do
        if [ ! -f "$INSTALL_DIR/$file" ]; then
            error "Missing file: $INSTALL_DIR/$file"
            missing_files=1
        fi
    done
    
    if [ $missing_files -eq 0 ]; then
        success "Claude CLI installed successfully!"
        echo
        if ! grep -q "^ANTHROPIC_API_KEY=your_api_key_here$" "$INSTALL_DIR/credentials"; then
            echo "Installation complete! To use Claude CLI:"
            echo "1. Start a new shell or run:"
            echo "   source $INSTALL_DIR/bin/claude-cli"
        else
            echo "Almost done! To complete setup:"
            echo "1. Add your API key by editing $INSTALL_DIR/credentials"
            echo "   Get your key from: https://console.anthropic.com/dashboard"
            echo
            echo "2. Start a new shell or run:"
            echo "   source $INSTALL_DIR/bin/claude-cli"
        fi
        echo
        echo "For more information, visit: https://github.com/goodlux/claude-cli"
    else
        error "Installation verification failed"
        exit 1
    fi
}

# Main installation flow
main() {
    debug "Starting installation..."
    debug "Use local files: $USE_LOCAL"
    
    echo "Installing Claude CLI..."
    [ "$USE_LOCAL" = true ] && echo "Installing from local repository"
    [ "$USE_LOCAL" = false ] && echo "Installing from remote repository"
    
    check_dependencies
    setup_directory
    setup_credentials
    install_files
    configure_shell
    verify_installation
}

main "$@"