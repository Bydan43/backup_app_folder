#!/bin/bash

# Script Name: backup_apps.sh
# Description: This script is used to create backups of specified application directories.
#              It compresses the directories into tar.gz archives, checks their integrity,
#              and deletes backups older than a specified number of days.
# Author: Your Name
# Version: 1.0
# Date: $(date '+%Y-%m-%d')

set -e

# Backup directory and storage time configuration
BACKUP_DIR=${BACKUP_DIR:-"/data/_backups"}
BACKUP_STORAGE_TIME=${BACKUP_STORAGE_TIME:-10}  # Backup retention period in days
DATATIME=$(date '+%d-%m-%Y-%H:%M:%S')

# Log file for storing backup process logs
LOG_FILE="/var/log/backup_apps.log"

# List of application directories to back up
APPS_DIR=(
    "/data/apps/vaultwarden"
    "/data/apps/angie"
)

# Logging function
log() {
    local level=$1
    local message=$2
    echo "${DATATIME} - [${level}] - ${message}"
}

# Function to check backup integrity
check_backup_integrity() {
    local backup_file=$1
    if ! gzip -t "$backup_file"; then
        log "ERROR" "Backup integrity check failed for $backup_file"
        return 1
    fi
    return 0
}

# Function to create backups
create_backup() {
    local app_dir=$1
    local backup_dir=$2

    app=$(basename "${app_dir}")
    backup_date=$(date '+%d-%m-%Y')
    
    log "INFO" "* Starting backup for app: $app *"

    # Get the size of the original data
    original_size=$(du -sb "${app_dir}" | awk '{print $1}')
    log "INFO" "  - Original size: ${original_size} bytes"

    # Check if the directory is empty
    if [ -z "$(ls -A ${app_dir})" ]; then
        log "WARN" "  - Directory is empty, skipping backup."
        log "INFO" "* Backup for $app skipped *"
        echo ""  # Empty line for separation
        return
    fi

    # Create a compressed backup archive
    cd "${app_dir}" || { log "ERROR" "  - Failed to cd to ${app_dir}"; exit 1; }
    tar czf "${backup_dir}/${backup_date}-${app}.tar.gz" ./ || {
        log "ERROR" "  - Failed to create backup for ${app}"
        exit 1
    }

    # Check backup integrity
    if check_backup_integrity "${backup_dir}/${backup_date}-${app}.tar.gz"; then
        log "INFO" "  - Backup integrity check passed."
    else
        log "ERROR" "  - Backup integrity check failed."
        exit 1
    fi

    # Get the size of the compressed archive
    compressed_size=$(du -b "${backup_dir}/${backup_date}-${app}.tar.gz" | awk '{print $1}')
    log "INFO" "  - Compressed size: ${compressed_size} bytes"

    # Calculate the compression ratio
    compression_ratio=$(echo "scale=2; (1 - ${compressed_size}/${original_size}) * 100" | bc)
    log "INFO" "  - Compression ratio: ${compression_ratio}%"

    log "SUCCESS" "  - Backup created: ${backup_date}-${app}.tar.gz"
    log "INFO" "* Backup for $app completed *"
    echo ""  # Empty line for separation
}

# Redirect output to the log file
exec >> "$LOG_FILE" 2>&1

# Check for required dependencies
dependencies=("tar" "gzip" "find" "du" "bc")
for cmd in "${dependencies[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        log "ERROR" "Command '$cmd' is required but not installed."
        exit 1
    fi
done

# Delete old backups
log "INFO" "Deleting backups older than $BACKUP_STORAGE_TIME days..."
find "$BACKUP_DIR" -type f -mtime +${BACKUP_STORAGE_TIME} -print -delete
log "INFO" "Old backups deletion completed"
echo ""

# Start the backup process
log "INFO" "##### Backup process started #####"

# Check if the backup directory exists, create it if not
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR" || { log "ERROR" "Failed to create backup directory: $BACKUP_DIR"; exit 1; }
fi

# Check for sufficient free space
MIN_FREE_SPACE=10485760  # 10 GB in kilobytes
free_space=$(df -k "$BACKUP_DIR" | awk 'NR==2 {print $4}')
if [ "$free_space" -lt "$MIN_FREE_SPACE" ]; then
    log "ERROR" "Not enough free space in $BACKUP_DIR"
    exit 1
fi

# Create backups for each application directory
for app in "${APPS_DIR[@]}"; do
    if [ -d "${app}" ]; then
        create_backup "${app}" "${BACKUP_DIR}"
    else
        log "WARN" "Directory ${app} does not exist, skipping."
    fi
done

log "SUCCESS" "##### Backup process completed successfully #####"
