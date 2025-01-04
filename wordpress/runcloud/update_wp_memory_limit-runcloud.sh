#!/bin/bash

# Generate a log file name with the current date and time
LOG_FILE="update_wp_memory_limit_$(date +'%Y-%m-%d_%H-%M-%S').log"

# Function to log actions and outputs
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to execute shell commands as a specific user and capture output/error
run_as_user() {
    command="$1"
    user="$2"
    cwd="$3"
    if [ -n "$cwd" ]; then
        command="cd $cwd && $command"
    fi
    su - "$user" -c "$command" 2>&1
}

# Function to display the disclaimer and get user confirmation
confirm_disclaimer() {
    echo "=================================================="
    echo "DISCLAIMER:"
    echo "This script will check and update the WordPress"
    echo "memory limit for all installations found in"
    echo "/home/*/webapps/*."
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

log "Starting WordPress memory limit update process..."

# Main process
while IFS=: read -r user _ _ _ _ home_dir _; do
    if [[ $home_dir == /home/* ]]; then
        webapps_dir="${home_dir}/webapps"
        if [ -d "$webapps_dir" ]; then
            for site_dir in "$webapps_dir"/*; do
                if [ -d "$site_dir" ]; then
                    wp_install_dir="$site_dir"
                    if [ -f "${wp_install_dir}/wp-config.php" ]; then
                        log "Found WordPress installation for user $user at $wp_install_dir"

                        # Check if WP_MEMORY_LIMIT is already defined and update or add it
                        if grep -q "define( 'WP_MEMORY_LIMIT'," "${wp_install_dir}/wp-config.php"; then
                            log "Updating memory limit in ${wp_install_dir}/wp-config.php"
                            sed -i "s/define( 'WP_MEMORY_LIMIT'.*/define( 'WP_MEMORY_LIMIT', '$memory_limit' );/" "${wp_install_dir}/wp-config.php"
                        else
                            log "Setting memory limit in ${wp_install_dir}/wp-config.php"
                            sed -i "/\/\* That's all, stop editing! Happy publishing. \*\//i define( 'WP_MEMORY_LIMIT', '$memory_limit' );" "${wp_install_dir}/wp-config.php"
                        fi
                    fi
                fi
            done
        fi
    fi
done < /etc/passwd

log "Finished updating WordPress memory limits."
