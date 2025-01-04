#!/bin/bash

# Generate a log file name with the current date and time
LOG_FILE="system_update_$(date +'%Y-%m-%d_%H-%M-%S').log"

# Function to log actions and outputs
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to display the disclaimer and get user confirmation
confirm_disclaimer() {
    echo "=================================================="
    echo "DISCLAIMER:"
    echo "This script will check for and apply available"
    echo "system updates. This might cause services to restart."
    echo ""
    echo "Do you wish to continue?"
    echo "Type 'Y' to continue, 'N' to exit."
    echo "=================================================="
    echo -n "Enter your choice [Y/N]: "
    read -r confirmation

    case "$confirmation" in
        Y|y)
            echo "Proceeding with the system update..."
            log "User confirmed to proceed with system update."
            ;;
        N|n)
            echo "Exiting script. No changes made."
            log "User declined to proceed. Exiting script."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter 'Y' or 'N'."
            confirm_disclaimer
            ;;
    esac
}

# Start the script with disclaimer confirmation
confirm_disclaimer

# Start the system update process
log "Starting the system update process..."

# Update package list
log "Updating package list..."
sudo apt-get update 2>&1 | tee -a "$LOG_FILE"

# Upgrade all installed packages
log "Upgrading installed packages..."
sudo apt-get upgrade -y 2>&1 | tee -a "$LOG_FILE"

# Full distribution upgrade (if applicable)
log "Running full distribution upgrade (if applicable)..."
sudo apt-get dist-upgrade -y 2>&1 | tee -a "$LOG_FILE"

# Clean up unnecessary packages
log "Cleaning up unnecessary packages..."
sudo apt-get autoremove -y 2>&1 | tee -a "$LOG_FILE"
sudo apt-get autoclean -y 2>&1 | tee -a "$LOG_FILE"

log "System update process completed."
