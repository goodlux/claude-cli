#!/bin/bash
# Context gathering and system caching functionality

# Cache configuration
SYSTEM_CACHE="$USER_CONFIG_DIR/cache/system.json"
CACHE_TTL=86400  # 24 hours in seconds

update_system_cache() {
    # Check cache directory exists
    mkdir -p "$(dirname "$SYSTEM_CACHE")"
    
    local cache_data="{"
    
    # Check common tools
    local tools=(
        "git" "python" "python3" "node" "npm" "tree" "jq"
        "docker" "kubectl" "aws" "gcloud" "az"
    )
    
    cache_data+="\"tools\":{"
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            version=$($tool --version 2>/dev/null | head -n1 || echo "version unknown")
            cache_data+="\"$tool\":\"$version\","
        fi
    done
    cache_data="${cache_data%,}}"
    
    # Add system info
    cache_data+=",\"system\":{"
    cache_data+="\"os\":\"$OS_TYPE\","
    cache_data+="\"shell\":\"$SHELL\","
    cache_data+="\"cpu_cores\":$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "unknown")"
    cache_data+="}"
    
    cache_data+="}"
    
    echo "$cache_data" > "$SYSTEM_CACHE"
}

check_system_cache() {
    if [ ! -f "$SYSTEM_CACHE" ] || \
       [ $(( $(date +%s) - $(stat -f %m "$SYSTEM_CACHE" 2>/dev/null || stat -c %Y "$SYSTEM_CACHE" 2>/dev/null) )) -gt "$CACHE_TTL" ]; then
        update_system_cache
    fi
}

get_terminal_context() {
    local context=""
    
    # Include system capabilities
    check_system_cache
    if [ -f "$SYSTEM_CACHE" ]; then
        context+="System capabilities:\n"
        context+="$(cat "$SYSTEM_CACHE")\n\n"
    fi
    
    # Current directory info
    context+="Current directory: $(pwd)\n"
    context+="Files:\n$(ls -la)\n\n"
    
    # Recent history (using configured context lines)
    context+="Recent commands:\n"
    context+="$(history | tail -n ${CLAUDE_CLI_CONTEXT_LINES})\n\n"
    
    # Git context if in a repo
    if git rev-parse --git-dir > /dev/null 2>&1; then
        context+="Git status:\n$(git status)\n"
        context+="Recent commits:\n$(git log --oneline -n 5)\n\n"
    fi
    
    echo -e "$context"
}