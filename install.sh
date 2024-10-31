#!/bin/bash
set -e

# Configuration
INSTALL_DIR="$HOME/.claude-cli"
REPO_URL="https://raw.githubusercontent.com/goodlux/claude-cli/main"
SCRIPT_FILES=("bin/claude-cli" "bin/lib/context.sh" "bin/lib/settings.sh")
CONFIG_FILE="config/config.yml.example"

# Print colorized status messages
info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }
success() { echo -e "\033[0;32m[SUCCESS]\033[0m $1"; }
error() { echo -e "\033[0;31m[ERROR]\033[0m $1" >&2; }

# Check for required dependencies
check_dependencies() {
    info "Checking dependencies..."
    local missing_deps=()
    
    for cmd in curl jq yq; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        error "Missing required dependencies: ${missing_deps[*]}"
        echo "Please install them first:"
        echo "  - For Ubuntu/Debian: sudo apt-get install ${missing_deps[*]}"
        echo "  - For macOS: brew install ${missing_deps[*]}"
        exit 1
    fi
}

# Create installation directory structure
setup_directory() {
    info "Setting up installation directory..."
    mkdir -p "$INSTALL_DIR/bin/lib" "$INSTALL_DIR/cache"
}

# Download files
download_files() {
    info "Downloading Claude CLI files..."
    
    # Download main script and libraries
    for file in "${SCRIPT_FILES[@]}"; do
        local dir=$(dirname "$INSTALL_DIR/$file")
        mkdir -p "$dir"
        if ! curl -sSL "$REPO_URL/$file" -o "$INSTALL_DIR/$file"; then
            error "Failed to download $file"
            exit 1
        fi
        chmod 755 "$INSTALL_DIR/$file"
    done
    
    # Download config if it doesn't exist
    if [ ! -f "$INSTALL_DIR/config.yml" ]; then
        if ! curl -sSL "$REPO_URL/$CONFIG_FILE" -o "$INSTALL_DIR/config.yml"; then
            error "Failed to download config file"
            exit 1
        fi
        chmod 644 "$INSTALL_DIR/config.yml"
    else
        info "Config file already exists, skipping download"
    fi
    
    # Create empty credentials file if it doesn't exist
    if [ ! -f "$INSTALL_DIR/credentials" ]; then
        echo "# Anthropic API credentials" > "$INSTALL_DIR/credentials"
        echo "ANTHROPIC_API_KEY=your_api_key_here" >> "$INSTALL_DIR/credentials"
        chmod 600 "$INSTALL_DIR/credentials"
    fi
}

# Configure shell
configure_shell() {
    info "Configuring shell..."
    local shell_config
    
    # Determine shell config file
    case "$SHELL" in
        */zsh) shell_config="$HOME/.zshrc" ;;
        */bash) shell_config="$HOME/.bashrc" ;;
        *) 
            error "Unsupported shell: $SHELL"
            echo "Please manually add: source $INSTALL_DIR/bin/claude-cli"
            return 1
            ;;
    esac
    
    # Add source line if not already present
    if ! grep -q "source.*$INSTALL_DIR/bin/claude-cli" "$shell_config"; then
        echo "source $INSTALL_DIR/bin/claude-cli" >> "$shell_config"
        success "Added Claude CLI to $shell_config"
    else
        info "Claude CLI already configured in $shell_config"
    fi
}

# Verify installation
verify_installation() {
    info "Verifying installation..."
    
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
        echo "To complete installation:"
        echo "1. Set up your API key:"
        echo "   edit $INSTALL_DIR/credentials"
        echo "   Replace 'your_api_key_here' with your Anthropic API key"
        echo
        echo "2. Start a new shell or run:"
        echo "   source $INSTALL_DIR/bin/claude-cli"
        echo
        echo "For more information, visit: https://github.com/goodlux/claude-cli"
    else
        error "Installation verification failed"
        exit 1
    fi
}

# Main installation flow
main() {
    echo "Installing Claude CLI..."
    echo "Repository: https://github.com/goodlux/claude-cli"
    check_dependencies
    setup_directory
    download_files
    configure_shell
    verify_installation
}

main "$@"