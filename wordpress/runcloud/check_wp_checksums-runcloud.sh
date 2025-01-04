#!/bin/bash

# Generate a log file name with the current date and time
LOG_FILE="check_wp_checksums_$(date +'%Y-%m-%d_%H-%M-%S').log"
error_found=false # Flag to track if any errors were found

# Function to log actions and outputs
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to display the disclaimer and get user confirmation
confirm_disclaimer() {
    echo "=================================================="
    echo "DISCLAIMER:"
    echo "This script will check the integrity of WordPress"
    echo "installations found in /home/*/webapps/*."
    echo "It will verify checksums and identify any potential issues."
    echo ""
    echo "Do you wish to continue?"
    echo "Type 'Y' to continue, 'N' to exit."
    echo "=================================================="
    echo -n "Enter your choice [Y/N]: "
    read -r confirmation

    case "$confirmation" in
        Y|y)
            echo "Proceeding with the WordPress checksums verification..."
            log "User confirmed to proceed with WordPress checksums verification."
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

log "Starting WordPress maintenance process..."

for user_dir in /home/*; do
    for wp_dir in "$user_dir"/webapps/*; do
        if [ -f "$wp_dir"/wp-config.php ]; then
            wp_install_dir="$wp_dir"
            user=$(basename "$user_dir")

            log "Processing WordPress site in $wp_install_dir for user $user"
            checksum_output=$(su - "$user" -c "cd $wp_install_dir; wp core verify-checksums --include-root" 2>&1)
            log "$checksum_output"

            # Filter out specific warnings and ignore them
            ignore_warnings="readme.html|.user.ini|wordfence-waf.php|.htaccess.bk"
            filtered_output=$(echo "$checksum_output" | egrep -v "$ignore_warnings")

            # Check if the filtered output is empty or only contains the checksum error
            if [[ ! $(echo "$filtered_output" | grep -v "Error: WordPress installation doesn't verify against checksums.") ]]; then
                # Consider the installation verified if the filtered output does not contain any other errors
                log "WordPress is verified for $wp_install_dir despite the checksum error and ignored warnings."
            else
                if echo "$filtered_output" | grep -q "Error: WordPress installation doesn't verify against checksums."; then
                    error_found=true # Set flag to true if any non-ignored error is found
                    log "Error: WordPress installation failed verification at $wp_install_dir"
                    log "$filtered_output"
                else
                    log "Maintenance completed for $wp_install_dir without significant errors."
                fi
            fi

            log "Maintenance completed for $wp_install_dir"
        else
            log "No WordPress installations found in $wp_dir for user $user."
        fi
    done
done

if $error_found; then
    log "One or more WordPress installations failed verification."
else
    log "All WordPress installations passed verification."
fi

log "Finished processing all WordPress sites."
