#!/bin/bash

# Generate a log file name with the current date and time
LOG_FILE="check_wp_checksums_$(date +'%Y-%m-%d_%H-%M-%S').log"

# Function to log actions and outputs
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to display the disclaimer and get user confirmation
confirm_disclaimer() {
    echo "=================================================="
    echo "DISCLAIMER:"
    echo "This script will check the integrity of WordPress"
    echo "installations for all users with home directories"
    echo "in /var/www."
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

# Start processing WordPress sites
log "Starting WordPress checksums verification for all relevant users..."

# Parse /etc/passwd to find users with their home directory in /var/www
grep ":/var/www/" /etc/passwd | while read -r user_entry; do
    user=$(echo "$user_entry" | cut -d: -f1)
    home_dir=$(echo "$user_entry" | cut -d: -f6)
    wp_install_dir="$home_dir/public_html"

    if [ -d "$wp_install_dir" ] && [ -f "$wp_install_dir/wp-config.php" ]; then
        log "Processing WordPress site in $wp_install_dir for user $user"
        
        # Run the checksum verification
        checksum_output=$(su - "$user" -c "wp core verify-checksums --path=$wp_install_dir --include-root" 2>&1)
        
        # Filter out specific warnings and ignore them
        ignore_warnings="readme.html|.user.ini|wordfence-waf.php|.htaccess.bk"
        filtered_output=$(echo "$checksum_output" | egrep -v "$ignore_warnings")

        if echo "$filtered_output" | grep -q "Error: WordPress installation doesn't verify against checksums."; then
            log "Error: WordPress installation failed verification at $wp_install_dir"
            log "$filtered_output"
        else
            log "Maintenance completed for $wp_install_dir without significant errors."
        fi

        log "Maintenance completed for $wp_install_dir."
    else
        log "No WordPress installations found in $wp_install_dir for $user."
    fi
done

log "Finished processing all WordPress sites."
