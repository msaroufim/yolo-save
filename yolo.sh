#!/bin/bash

# Function to handle git operations
push_changes() {
    local file=$1
    git add -A
    GIT_EDITOR=: git commit -m "yolo: updated at $(date '+%H:%M:%S')"
    git push origin $(git branch --show-current)
}

# Function to setup and start file watching
setup_fswatch() {
    echo "👀 Watching for changes (Ctrl+C to stop)..."
    echo "📍 Currently in directory: $(pwd)"
    echo "🌿 On branch: $(git branch --show-current)"
    
    fswatch -0 --exclude '\.git/' . | while read -d '' file
    do
        echo "📄 File changed: $file"
        if [[ -n $(git status --porcelain) ]]; then
            push_changes "$file"
        fi
    done
}

# Start the watcher
setup_fswatch