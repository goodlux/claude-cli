#!/bin/bash
# claude-cli: Natural language interface for bash using Claude API
# Installation: Save as ~/.claude-cli/claude-cli.sh and source it in your .bashrc

# Configuration
CLAUDE_CLI_CONFIG_DIR="$HOME/.claude-cli"
CLAUDE_CLI_HISTORY="$CLAUDE_CLI_CONFIG_DIR/history.txt"
CLAUDE_CLI_CONFIG="$CLAUDE_CLI_CONFIG_DIR/config.yml"
CLAUDE_CLI_CREDENTIALS="$CLAUDE_CLI_CONFIG_DIR/credentials"
CLAUDE_CLI_MODEL="${CLAUDE_CLI_MODEL:-claude-3-sonnet}"
CLAUDE_CLI_CONTEXT_LINES="${CLAUDE_CLI_CONTEXT_LINES:-1000}"

# Ensure config directory exists
[ ! -d "$CLAUDE_CLI_CONFIG_DIR" ] && mkdir -p "$CLAUDE_CLI_CONFIG_DIR"

# Create credentials file if it doesn't exist
if [ ! -f "$CLAUDE_CLI_CREDENTIALS" ]; then
    cat > "$CLAUDE_CLI_CREDENTIALS" << EOL
# Anthropic API credentials
ANTHROPIC_API_KEY=your_api_key_here
EOL
    chmod 600 "$CLAUDE_CLI_CREDENTIALS"
fi

# Source credentials
source "$CLAUDE_CLI_CREDENTIALS"

# Create default config if it doesn't exist
if [ ! -f "$CLAUDE_CLI_CONFIG" ]; then
    cat > "$CLAUDE_CLI_CONFIG" << EOL
model: claude-3-sonnet
context_lines: 1000
safety:
  confirm_destructive: true
  dry_run: false
api:
  timeout: 30
  max_retries: 3
  endpoint: https://api.anthropic.com/v1/messages
EOL
fi

# Helper function to capture terminal context
get_terminal_context() {
    local context=""

    # Current directory info
    context+="Current directory: $(pwd)\n"
    context+="Files:\n$(ls -la)\n\n"

    # Recent history
    context+="Recent commands:\n"
    context+="$(history | tail -n $CLAUDE_CLI_CONTEXT_LINES)\n\n"

    # Git context if in a repo
    if git rev-parse --git-dir > /dev/null 2>&1; then
        context+="Git status:\n$(git status)\n"
        context+="Recent commits:\n$(git log --oneline -n 5)\n\n"
    fi

    # Environment snapshot (filtered for relevance)
    context+="Environment:\n"
    context+="$(env | grep -E '^(PATH|PWD|HOME|SHELL|TERM|USER)=')\n\n"

    echo -e "$context"
}

# Helper function to call Claude API
call_claude_api() {
    local prompt="$1"
    local context="$2"

    if [ -z "$ANTHROPIC_API_KEY" ] || [ "$ANTHROPIC_API_KEY" = "your_api_key_here" ]; then
        echo "Error: API key not configured. Please edit ~/.claude-cli/credentials"
        return 1
    }

    # Actual API call using curl
    response=$(curl -s -X POST "https://api.anthropic.com/v1/messages" \
        -H "x-api-key: $ANTHROPIC_API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        -H "content-type: application/json" \
        -d "{
            \"model\": \"$CLAUDE_CLI_MODEL\",
            \"messages\": [{
                \"role\": \"user\",
                \"content\": \"Context:\\n$context\\n\\nRequest: Convert this request into a bash command: $prompt\\n\\nRespond in this format only:\\nsuggested_command: <command>\\nexplanation: <explanation>\"
            }]
        }")

    # Extract command and explanation from response
    echo "$response" | jq -r '.content[0].text' 2>/dev/null || echo "$response"
}

# Helper function to confirm command execution
confirm_execution() {
    local cmd="$1"
    local explanation="$2"

    echo -e "\nSuggested command: $cmd"
    echo -e "Explanation: $explanation\n"

    read -p "Execute this command? [y/n/e(edit)] " choice

    case "$choice" in
        y|Y) return 0 ;;
        n|N) return 1 ;;
        e|E)
            read -p "Edit command: " -e -i "$cmd" edited_cmd
            if [ -n "$edited_cmd" ]; then
                confirm_execution "$edited_cmd" "$explanation"
                return $?
            fi
            return 1
            ;;
        *) return 1 ;;
    esac
}

# Main claude-cli function
claude_cli() {
    # Show help if no arguments
    if [ $# -eq 0 ]; then
        echo "Usage: claude_cli 'natural language command description'"
        echo "Example: claude_cli 'find all python files modified in the last week'"
        return 1
    }

    # Capture the natural language request
    local request="$*"

    # Get terminal context
    local context=$(get_terminal_context)

    # Call Claude API
    local response=$(call_claude_api "$request" "$context")

    # Parse response
    local suggested_cmd=$(echo "$response" | grep '^suggested_command: ' | cut -d' ' -f2-)
    local explanation=$(echo "$response" | grep '^explanation: ' | cut -d' ' -f2-)

    # Confirm and execute
    if [ -n "$suggested_cmd" ]; then
        if confirm_execution "$suggested_cmd" "$explanation"; then
            # Log to history
            echo "$(date '+%Y-%m-%d %H:%M:%S')|$request|$suggested_cmd" >> "$CLAUDE_CLI_HISTORY"

            # Execute the command
            eval "$suggested_cmd"
        fi
    else
        echo "Sorry, I couldn't generate a command for that request."
    fi
}

# Alias for easier access
alias ccli='claude_cli'

# Add command completion (basic version)
_claude_cli_complete() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev_cmds=$(tail -n 10 "$CLAUDE_CLI_HISTORY" | cut -d'|' -f2 | sort -u)

    COMPREPLY=($(compgen -W "$prev_cmds" -- "$cur"))
}

complete -F _claude_cli_complete claude_cli
complete -F _claude_cli_complete ccli

echo "Claude CLI loaded. Use 'claude_cli' or 'ccli' to start."
