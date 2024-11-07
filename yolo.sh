#!/bin/bash

# Function to handle git operations
push_changes() {
    echo "🔄 Pushing changes..."
    git add .
    git commit -m "auto: $(date '+%H:%M:%S')" || true
    git push origin "$(git branch --show-current)"
    echo "✅ Done!"
}

# Function to setup and start file watching
watch_files() {
    echo "👀 Watching for changes (Ctrl+C to stop)..."
    echo "📍 $(pwd)"
    echo "🌿 $(git branch --show-current)"
    
    fswatch -0 . | while read -d "" event
    do
        if [[ ! "$event" =~ .git/ ]]; then
            push_changes
        fi
    done
}

# Start watching
watch_files