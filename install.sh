#!/bin/bash
set -e

# Debug mode
DEBUG=false
[ "$1" = "--debug" ] && DEBUG=true

# Configuration
INSTALL_DIR="$HOME/.claude-cli"
SCRIPT_FILES=(
    "config/bin/claude-cli"
    "config/bin/lib/context.sh"
    "config/bin/lib/settings.sh"
    "config/bin/lib/shell.sh"
)
CONFIG_FILE="config/config.yml.example"

# Debug function
debug() {
    if [ "$DEBUG" = true ]; then
        echo -e "\033[0;35m[DEBUG]\033[0m $1"
    fi
}

# Print colorized status messages
info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }
success() { echo -e "\033[0;32m[SUCCESS]\033[0m $1"; }
error() { echo -e "\033[0;31m[ERROR]\033[0m $1" >&2; }

# Check for required dependencies
check_dependencies() {
    debug "Checking dependencies..."
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
    debug "Creating directory structure at $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR/bin/lib" "$INSTALL_DIR/cache"
}

# Handle API key input
setup_credentials() {
    debug "Setting up credentials..."
    
    if [ -f "$INSTALL_DIR/credentials" ]; then
        debug "Existing credentials file found"
        return 0
    fi
    
    echo "Please enter your Anthropic API key"
    echo "You can find your API key at: https://console.anthropic.com/dashboard"
    echo "If you don't have one yet, press Enter to skip and add it later"
    echo -n "API key: "
    read -r api_key
    
    if [ -n "$api_key" ]; then
        debug "Writing API key to credentials file"
        echo "# Anthropic API credentials" > "$INSTALL_DIR/credentials"
        echo "ANTHROPIC_API_KEY=$api_key" >> "$INSTALL_DIR/credentials"
        chmod 600 "$INSTALL_DIR/credentials"
        success "API key configured"
    else
        debug "Creating empty credentials file"
        echo "# Anthropic API credentials" > "$INSTALL_DIR/credentials"
        echo "# Get your API key from: https://console.anthropic.com/dashboard" >> "$INSTALL_DIR/credentials"
        echo "ANTHROPIC_API_KEY=your_api_key_here" >> "$INSTALL_DIR/credentials"
        chmod 600 "$INSTALL_DIR/credentials"
        info "No API key provided. You can add it later by editing $INSTALL_DIR/credentials"
    fi
}

# Install files from local source
install_files() {
    info "Installing files..."
    
    for file in "${SCRIPT_FILES[@]}"; do
        debug "Processing $file"
        # Get the destination path by removing 'config/' prefix
        local dest_file=${file#config/}
        local dest_dir=$(dirname "$INSTALL_DIR/$dest_file")
        
        debug "Creating directory: $dest_dir"
        mkdir -p "$dest_dir"
        
        if [ -f "$file" ]; then
            debug "Copying $file to $INSTALL_DIR/$dest_file"
            cp "$file" "$INSTALL_DIR/$dest_file"
            chmod 755 "$INSTALL_DIR/$dest_file"
            success "Installed $dest_file"
        else
            error "Missing file: $file"
            exit 1
        fi
    done
    
    if [ ! -f "$INSTALL_DIR/config.yml" ] && [ -f "$CONFIG_FILE" ]; then
        debug "Installing config file"
        cp "$CONFIG_FILE" "$INSTALL_DIR/config.yml"
        chmod 644 "$INSTALL_DIR/config.yml"
        success "Installed config.yml"
    fi
}

# Configure shell
configure_shell() {
    debug "Configuring shell..."
    
    # Source shell.sh for its functions
    source "$INSTALL_DIR/bin/lib/shell.sh"
    
    # Use the shell detection function from shell.sh
    local result=$(setup_shell_config "$INSTALL_DIR")
    local status=$?
    
    case $status in
        0) success "Shell configuration added" ;;
        1) error "Shell configuration failed" ;;
        2) info "Shell already configured" ;;
    esac
}

# Verify installation
verify_installation() {
    debug "Verifying installation..."
    
    local missing_files=0
    for file in "${SCRIPT_FILES[@]}"; do
        local dest_file=${file#config/}
        if [ ! -f "$INSTALL_DIR/$dest_file" ]; then
            error "Missing file: $INSTALL_DIR/$dest_file"
            missing_files=1
        fi
    done
    
    if [ $missing_files -eq 0 ]; then
        show_terminal_art
        show_branding
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
    else
        error "Installation verification failed"
        exit 1
    fi
}

# ASCII art display function
show_terminal_art() {
    local BLUE=$(tput setaf 4)
    local RESET=$(tput sgr0)
    
    echo
    echo "${BLUE}"
    cat << "EOF"
     ▄████▄   ██▓    ▄▄▄       █    ██ ▓█████▄ ▓█████ 
    ▒██▀ ▀█  ▓██▒   ▒████▄     ██  ▓██▒▒██▀ ██▌▓█   ▀ 
    ▒▓█    ▄ ▒██░   ▒██  ▀█▄  ▓██  ▒██░░██   █▌▒███   
    ▒▓▓▄ ▄██▒▒██░   ░██▄▄▄▄██ ▓▓█  ░██░░▓█▄   ▌▒▓█  ▄ 
    ▒ ▓███▀ ░░██████▒▓█   ▓██▒▒▒█████▓ ░▒████▓ ░▒████▒
    ░ ░▒ ▒  ░░ ▒░▓  ░▒▒   ▓▒█░░▒▓▒ ▒ ▒  ▒▒▓  ▒ ░░ ▒░ ░
      ░  ▒   ░ ░ ▒  ░ ▒   ▒▒ ░░░▒░ ░ ░  ░ ▒  ▒  ░ ░  ░
    ░          ░ ░    ░   ▒    ░░░ ░ ░  ░ ░  ░    ░   
    ░ ░          ░  ░     ░  ░   ░        ░       ░  ░
    ░                                    ░             
EOF
    echo "${RESET}"
    sleep 0.5
}

# Terminal animation utilities
show_branding() {
    # Use tput for colors and cursor control
    local RED=$(tput setaf 1)
    local GREEN=$(tput setaf 2)
    local YELLOW=$(tput setaf 3)
    local BLUE=$(tput setaf 4)
    local MAGENTA=$(tput setaf 5)
    local CYAN=$(tput setaf 6)
    local RESET=$(tput sgr0)
    
    # Hide cursor
    tput civis
    
    # Cleanup on exit or interrupt
    trap 'tput cnorm; echo' EXIT INT
    
    # Simple spinner
    local SPINNER=('-' '\' '|' '/')
    
    echo
    
    # Typing effect for "powered by"
    local TEXT="powered by "
    for ((i=0; i<${#TEXT}; i++)); do
        echo -n "${TEXT:$i:1}"
        sleep 0.03
    done
    
    echo -n "CLAUDE"
    sleep 0.5
    
    # Delete animation
    for ((i=6; i>=0; i--)); do
        tput cr  # Return to start of line
        tput el  # Clear to end of line
        echo -n "$TEXT"
        printf "%-${i}s" "CLAUDE"
        sleep 0.1
    done
    
    # Colorful typing animation with spinner
    for ((i=0; i<6; i++)); do
        for ((s=0; s<4; s++)); do
            tput cr
            tput el
            echo -n "$TEXT"
            
            case $i in
                0) echo -n "${RED}C${RESET}" ;;
                1) echo -n "${RED}C${GREEN}L${RESET}" ;;
                2) echo -n "${RED}C${GREEN}L${BLUE}A${RESET}" ;;
                3) echo -n "${RED}C${GREEN}L${BLUE}A${MAGENTA}U${RESET}" ;;
                4) echo -n "${RED}C${GREEN}L${BLUE}A${MAGENTA}U${CYAN}D${RESET}" ;;
                5) echo -n "${RED}C${GREEN}L${BLUE}A${MAGENTA}U${CYAN}D${YELLOW}E${RESET}" ;;
            esac
            
            echo -n " ${SPINNER[s]}"
            sleep 0.1
        done
    done
    
    # Final display with rainbow colors
    tput cr
    tput el
    echo -n "$TEXT${RED}C${GREEN}L${BLUE}A${MAGENTA}U${CYAN}D${YELLOW}E${RESET}"
    echo
    echo
    
    # Show cursor
    tput cnorm
}

# Main installation flow
main() {
    debug "Starting installation..."
    
    echo "Installing Claude CLI..."
    check_dependencies
    setup_directory
    setup_credentials
    install_files
    configure_shell
    verify_installation
}

main "$@"