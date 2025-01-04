#!/bin/bash

# Generate a log file name with the current date and time
LOG_FILE="check_all_crons_$(date +'%Y-%m-%d_%H-%M-%S').log"

# Function to log actions and outputs
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to display the disclaimer and get user confirmation
confirm_disclaimer() {
    echo "=================================================="
    echo "DISCLAIMER:"
    echo "This script will check all possible cron jobs for"
    echo "each system user."
    echo ""
    echo "Do you wish to continue?"
    echo "Type 'Y' to continue, 'N' to exit."
    echo "=================================================="
    echo -n "Enter your choice [Y/N]: "
    read -r confirmation

    case "$confirmation" in
        Y|y)
            echo "Proceeding with the script..."
            log "User confirmed to proceed with checking cron jobs."
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

# Start the cron job checking process
log "Starting to check cron jobs for all users..."

# Loop through each user and check their cron jobs
for user in $(cut -f1 -d: /etc/passwd); do
    log "Cron jobs for user: $user"
    cron_jobs=$(crontab -u "$user" -l 2>&1)
    
    if [[ $cron_jobs == *"no crontab for"* ]]; then
        log "No cron jobs for $user"
    else
        log "$cron_jobs"
    fi
    
    log "--------------------------------------"
done

log "Completed checking all users' cron jobs."
