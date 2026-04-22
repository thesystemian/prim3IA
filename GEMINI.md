# PRIM3IA Project

Project structure and sync management for the PRIM3IA system.

## Custom Commands

Use these commands to manage your PRIM3IA environment:

- **Sync Up**: `bash ~/prim3IA/drive-sync/sync-manager.sh up`
- **Sync Down**: `bash ~/prim3IA/drive-sync/sync-manager.sh down`
- **Sync Both**: `bash ~/prim3IA/drive-sync/sync-manager.sh both`
- **Status**: `echo 'PRIM Status:'; ps aux | grep prim; df -h ~/prim3IA`
- **Activate**: `cd ~/prim3IA && python3 core/orchestrator.py`
- **Logs**: `tail -f ~/prim3IA/logs/*.log`

## Setup Instructions

1. **Gdrive Auth**: Run `gdrive account add` and follow the instructions to link your Google account.
2. **Drive Folder**: Create the folder on Drive: `gdrive files mkdir "prim3IA"`.
3. **Configuration**: Update `DRIVE_FOLDER_ID` in `~/prim3IA/drive-sync/sync-manager.sh` with the ID provided by the previous command.
