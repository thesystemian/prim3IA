#!/bin/bash
# PRIM3IA DRIVE SYNC MANAGER
# Gemini CLI command: gemini run prim sync --direction up/down/both

set -e

DRIVE_FOLDER_ID="YOUR_GDRIVE_FOLDER_ID"  # À remplir après gdrive mkdir
LOCAL_PATH="$HOME/prim3IA"
LOG_FILE="$LOCAL_PATH/logs/sync.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# UPLOAD (local → Drive)
sync_up() {
    log "🔄 Syncing UP: Local → Google Drive"
    
    # Upload important docs
    gdrive files upload --parent $DRIVE_FOLDER_ID \
        "$LOCAL_PATH/PHILOSOPHY.md"
    
    gdrive files upload --parent $DRIVE_FOLDER_ID \
        "$LOCAL_PATH/ARCHITECTURE.md"
    
    # Upload config
    gdrive files upload --parent $DRIVE_FOLDER_ID \
        "$LOCAL_PATH/config/prim-config.yml"
    
    log "✅ Upload complete"
}

# DOWNLOAD (Drive → local)
sync_down() {
    log "🔄 Syncing DOWN: Google Drive → Local"
    
    # Assuming Drive has updates we need
    gdrive files download --recursive --destination "$LOCAL_PATH" \
        $DRIVE_FOLDER_ID
    
    log "✅ Download complete"
}

# BIDIRECTIONAL (smart merge)
sync_both() {
    log "🔄 Syncing BOTH directions (smart merge)"
    
    # Download first
    sync_down
    
    # Then upload (overwrites Drive with latest local)
    sync_up
    
    log "✅ Bidirectional sync complete"
}

# MAIN
case "${1:-both}" in
    up)
        sync_up
        ;;
    down)
        sync_down
        ;;
    both)
        sync_both
        ;;
    *)
        echo "Usage: $0 {up|down|both}"
        exit 1
        ;;
esac

log "📊 Sync status: OK"
