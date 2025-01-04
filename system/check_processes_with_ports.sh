#!/bin/bash

# Generate a log file name with the current date and time
LOG_FILE="check_processes_with_ports_$(date +'%Y-%m-%d_%H-%M-%S').log"

# Function to log actions and outputs
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to display the disclaimer and get user confirmation
confirm_disclaimer() {
    echo "=================================================="
    echo "DISCLAIMER:"
    echo "This script will check all running processes with"
    echo "open ports for each system user."
    echo ""
    echo "Do you wish to continue?"
    echo "Type 'Y' to continue, 'N' to exit."
    echo "=================================================="
    echo -n "Enter your choice [Y/N]: "
    read -r confirmation

    case "$confirmation" in
        Y|y)
            echo "Proceeding with the script..."
            log "User confirmed to proceed with checking processes with open ports."
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

# Start checking running processes with open ports
log "Starting to check running processes with open ports for all users..."

# Loop through each user and check their running processes with open ports
cut -f1 -d: /etc/passwd | while read -r user; do
    echo "Running processes with open ports for $user:" | tee -a "$LOG_FILE"
    ps -u "$user" -o pid=,comm= --no-headers 2>/dev/null | while read -r pid comm; do
        # Check if the process has any open ports
        if lsof_output=$(lsof -nP -i -a -p "$pid" 2>/dev/null); then
            if [ -n "$lsof_output" ]; then
                echo "$comm $pid" | tee -a "$LOG_FILE"
                echo "$lsof_output" | grep -v CLOSE_WAIT | awk '{print $1, $9}' | tee -a "$LOG_FILE"
            fi
        fi
    done
    echo "--------------------------------------" | tee -a "$LOG_FILE"
done

log "Completed checking all users' running processes with open ports."
