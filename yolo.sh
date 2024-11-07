#!/bin/bash

# Set default git pull behavior to avoid warnings
git config pull.rebase false

# Variables for debouncing
LAST_UPDATE=0
DEBOUNCE_DELAY=2  # seconds

# Function to handle git operations
push_changes() {
    local current_time=$(date +%s)
    
    # Debounce: only push if enough time has passed since last update
    if (( current_time - LAST_UPDATE < DEBOUNCE_DELAY )); then
        return
    fi
    LAST_UPDATE=$current_time

    # Check if there are actual changes
    if ! git diff --quiet || ! git diff --staged --quiet; then
        echo "🔄 Changes detected, pushing..."
        
        # Stage and commit changes
        git add -A
        GIT_EDITOR=: git commit -m "auto: updated at $(date '+%H:%M:%S')" || true
        
        # Push changes, with a single retry on failure
        if ! git push origin $(git branch --show-current) 2>/dev/null; then
            echo "⚠️  Push failed, trying to pull first..."
            git pull --no-rebase
            git push origin $(git branch --show-current)
        fi
        
        echo "✅ Changes pushed successfully!"
    fi
}

# Function to setup and start file watching
setup_fswatch() {
    echo "👀 Watching for changes (Ctrl+C to stop)..."
    echo "📍 Currently in directory: $(pwd)"
    echo "🌿 On branch: $(git branch --show-current)"
    
    # Watch for changes, excluding git directory and temporary files
    fswatch -0 \
        --exclude '\.git/' \
        --exclude '\.swp$' \
        --exclude '\.swx$' \
        --exclude '~$' \
        . | while read -d '' file
    do
        echo "📄 File changed: $file"
        push_changes
    done
}

# Start the watcher
setup_fswatch