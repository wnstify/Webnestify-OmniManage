#!/bin/bash

# Generate a log file name with the current date and time
LOG_FILE="update_wp_memory_limit_$(date +'%Y-%m-%d_%H-%M-%S').log"

# Function to log actions and outputs
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to display the disclaimer and get user confirmation
confirm_disclaimer() {
    echo "=================================================="
    echo "DISCLAIMER:"
    echo "This script will check and update the WordPress"
    echo "memory limit for all installations found in /var/www."
    echo ""
    echo "You will be prompted to set the memory limit."
    echo "The ideal value is 256M."
    echo ""
    echo "Do you wish to continue?"
    echo "Type 'Y' to continue, 'N' to exit."
    echo "=================================================="
    echo -n "Enter your choice [Y/N]: "
    read -r confirmation

    case "$confirmation" in
        Y|y)
            echo "Proceeding with the WordPress memory limit update..."
            log "User confirmed to proceed with WordPress memory limit update."
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

# Function to prompt the user for a memory limit value
get_memory_limit() {
    echo "Please enter the desired WordPress memory limit (e.g., 256M):"
    read -r memory_limit
    if [[ -z "$memory_limit" ]]; then
        memory_limit="256M"
        echo "No input provided. Defaulting to 256M."
    fi
    log "User set the WordPress memory limit to $memory_limit."
}

# Start the script with disclaimer confirmation
confirm_disclaimer

# Get the memory limit from the user
get_memory_limit

# Main process
log "Starting WordPress memory limit update for all relevant users..."

grep ':/var/www/' /etc/passwd | while read -r user_entry; do
    user=$(echo "$user_entry" | cut -d: -f1)
    home_dir=$(echo "$user_entry" | cut -d: -f6)
    wp_install_dir="$home_dir/public_html"
    if [ -d "$wp_install_dir" ]; then
        find "$wp_install_dir" -type f -name wp-config.php | while read -r config_file; do
            if grep -q "define( 'WP_MEMORY_LIMIT'," "$config_file"; then
                # If WP_MEMORY_LIMIT is already defined, replace it with the new value
                sed -i "s/define( 'WP_MEMORY_LIMIT'.*/define( 'WP_MEMORY_LIMIT', '$memory_limit' );/" "$config_file"
                log "Updated memory limit in $config_file for user $user"
            else
                # If WP_MEMORY_LIMIT is not defined, add it before the stop editing comment
                sed -i "/\/\* That's all, stop editing! Happy publishing. \*\//i define( 'WP_MEMORY_LIMIT', '$memory_limit' );" "$config_file"
                log "Memory limit defined in $config_file for user $user"
            fi
        done
    else
        log "No WordPress installation found in $wp_install_dir for user $user."
    fi
done

log "Finished updating WordPress memory limits."
