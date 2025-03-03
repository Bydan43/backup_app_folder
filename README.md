# Backup Script for Application Directories

This script is designed to create compressed backups of specified application directories, check their integrity, and manage backup retention by deleting old backups.

## Table of Contents
1. [Overview](#overview)
2. [Features](#features)
3. [Requirements](#requirements)
4. [Configuration](#configuration)
5. [Usage](#usage)
6. [Logging](#logging)
7. [Backup Retention](#backup-retention)
8. [License](#license)

---

## Overview

The `backup_apps.sh` script automates the process of creating backups for specified application directories. It compresses the directories into `.tar.gz` archives, verifies their integrity, and deletes backups older than a specified number of days. The script logs all actions to a log file for easy monitoring and troubleshooting.

---

## Features

- **Backup Creation**: Compresses application directories into `.tar.gz` archives.
- **Integrity Check**: Verifies the integrity of each backup using `gzip`.
- **Logging**: Logs all actions and errors to `/var/log/backup_apps.log`.
- **Backup Retention**: Automatically deletes backups older than a specified number of days.
- **Space Check**: Ensures sufficient free space is available before starting the backup process.

---

## Requirements

- **Bash**: The script is written for Bash and requires a Bash shell to run.
- **Dependencies**: The following commands must be installed on the system:
  - `tar`
  - `gzip`
  - `find`
  - `du`
  - `bc`

---

## Configuration

### Environment Variables

The script uses the following environment variables for configuration:

- `BACKUP_DIR`: The directory where backups will be stored. Default: `/data/_backups`.
- `BACKUP_STORAGE_TIME`: The number of days to retain backups. Default: `10` days.

You can override these variables by exporting them before running the script:

```bash
export BACKUP_DIR="/path/to/backups"
export BACKUP_STORAGE_TIME=30
```

### Application Directories
The script backs up the directories listed in the APPS_DIR array. Modify this array to include the directories you want to back up:
```bash
APPS_DIR=(
    "/data/apps/vaultwarden"
    "/data/apps/angie"
)
```

---

## Usage

1. **Make the script executable:**
```bash
chmod +x backup_apps.sh
```
2. **Run the script:**
```bash
./backup_apps.sh
```
3. **Check the log file:**
The script logs all actions to /var/log/backup_apps.log. You can monitor the log file for progress and errors:
```bash
tail -f /var/log/backup_apps.log
```
---
## Logging
The script logs all actions and errors to /var/log/backup_apps.log. Log entries include timestamps, log levels (`INFO`, `WARN`, `ERROR`, `SUCCESS`), and descriptive messages.

Example log entries:
```log
01-01-2024-12:00:00 - [INFO] - * Starting backup for app: vaultwarden *
01-01-2024-12:00:05 - [SUCCESS] - Backup created: 01-01-2024-vaultwarden.tar.gz
01-01-2024-12:00:10 - [INFO] - Deleting backups older than 10 days...
```

---
## Backup Retention
The script automatically deletes backups older than the number of days specified in `BACKUP_STORAGE_TIME`. This ensures that old backups do not consume unnecessary disk space.

## License

All code in this repository is licensed under the terms of the `MIT License`. For further information please refer to the `LICENSE` file.


## Author

Bydanov Ilya
Email: bydanav@gmail.com
