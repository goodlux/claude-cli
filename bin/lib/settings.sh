#!/bin/bash
# Settings management functionality

# Load configuration
load_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        cp "$REPO_DIR/config/config.yml.example" "$CONFIG_FILE"
    fi
    
    # Update global variables from config
    if command -v yq >/dev/null 2>&1; then
        CLAUDE_CLI_MODEL=$(yq e '.model' "$CONFIG_FILE")
        CLAUDE_CLI_CONTEXT_LINES=$(yq e '.context_lines' "$CONFIG_FILE")
        
        # Load OS-specific settings
        if [[ "$OS_TYPE" == "macos" ]]; then
            DATE_CMD_RECENT=$(yq e '.os.macos.date_recent' "$CONFIG_FILE")
        else
            DATE_CMD_RECENT=$(yq e '.os.linux.date_recent' "$CONFIG_FILE")
        fi
    fi
}

claude_settings() {
    local action="$1"
    local setting="$2"
    local value="$3"
    
    case "$action" in
        get)
            if [ -z "$setting" ]; then
                cat "$CONFIG_FILE"
            else
                yq e ".$setting" "$CONFIG_FILE"
            fi
            ;;
            
        set)
            if [ -z "$setting" ] || [ -z "$value" ]; then
                echo "Usage: claude_settings set <setting> <value>"
                return 1
            fi
            yq e -i ".$setting = $value" "$CONFIG_FILE"
            echo "Updated $setting to $value"
            
            # Reload configuration
            load_config
            ;;
            
        help)
            echo "Claude CLI Settings Management"
            echo "Usage:"
            echo "  claude_settings get [setting]     - Show all settings or specific setting"
            echo "  claude_settings set <setting> <value> - Update setting"
            echo "  claude_settings help              - Show this help"
            echo
            echo "Available settings:"
            echo "  model              - Claude model to use (e.g., claude-3-sonnet-20240229)"
            echo "  context_lines      - Number of history lines to include"
            echo "  safety.confirm_destructive - Whether to confirm destructive commands"
            echo "  safety.dry_run     - Whether to run in dry-run mode"
            echo "  api.timeout        - API timeout in seconds"
            echo "  api.max_retries    - Maximum number of API retries"
            ;;
            
        *)
            echo "Unknown action: $action"
            echo "Try 'claude_settings help' for usage"
            return 1
            ;;
    esac
}

# Add completion for settings
_claude_settings_complete() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}
    
    case $COMP_CWORD in
        1)
            COMPREPLY=($(compgen -W "get set help" -- "$cur"))
            ;;
        2)
            if [ "$prev" = "get" ] || [ "$prev" = "set" ]; then
                COMPREPLY=($(compgen -W "model context_lines safety.confirm_destructive safety.dry_run api.timeout api.max_retries" -- "$cur"))
            fi
            ;;
    esac
}

complete -F _claude_settings_complete claude_settings

# Initialize settings on source
load_config