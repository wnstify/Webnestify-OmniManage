#!/bin/bash

# Generate a log file name with the current date and time
LOG_FILE="update_wp_plugins_themes_$(date +'%Y-%m-%d_%H-%M-%S').log"

# Function to log actions and outputs
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to execute commands as a specific user
run_as_user() {
    local command=$1
    local user=$2
    local cwd=$3

    if [[ -n "$cwd" ]]; then
        command="cd $cwd && $command"
    fi

    su - "$user" -c "$command"
}

# Function to display the disclaimer and get user confirmation
confirm_disclaimer() {
    echo "=================================================="
    echo "DISCLAIMER:"
    echo "This script will check and update all WordPress"
    echo "plugins and themes for users with home directories"
    echo "in /var/www."
    echo ""
    echo "Do you wish to continue?"
    echo "Type 'Y' to continue, 'N' to exit."
    echo "=================================================="
    echo -n "Enter your choice [Y/N]: "
    read -r confirmation

    case "$confirmation" in
        Y|y)
            echo "Proceeding with the WordPress plugins and themes update..."
            log "User confirmed to proceed with WordPress plugins and themes update."
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

# Main process
log "Starting WordPress plugins and themes update for all relevant users..."

while IFS=: read -r username _ _ _ _ home_dir _; do
    if [[ "$home_dir" == /var/www/* ]]; then
        wp_install_dir="$home_dir/public_html"
        if [[ -d "$wp_install_dir" && -f "$wp_install_dir/wp-config.php" ]]; then
            site_url=$(run_as_user "wp option get home --path=$wp_install_dir" "$username")

            if [[ -z "$site_url" ]]; then
                log "Error retrieving site URL for $username"
                continue
            fi

            log "Processing updates for user: $username ($site_url)"

            # Check for plugin updates
            plugin_updates=$(run_as_user "wp plugin list --update=available --path=$wp_install_dir --format=csv" "$username" "$wp_install_dir")
            if [[ -z "$plugin_updates" || "$plugin_updates" == "Plugin" ]]; then
                log "No plugin updates available for $site_url"
            else
                log "Plugin updates available for $site_url:"
                echo "$plugin_updates" | awk -F, 'NR>1 {print $1}' | while read -r plugin; do
                    log "Updating plugin: $plugin"
                    run_as_user "wp plugin update $plugin --path=$wp_install_dir" "$username" "$wp_install_dir"
                done
            fi

            # Check for theme updates
            theme_updates=$(run_as_user "wp theme list --update=available --path=$wp_install_dir --format=csv" "$username" "$wp_install_dir")
            if [[ -z "$theme_updates" || "$theme_updates" == "Theme" ]]; then
                log "No theme updates available for $site_url"
            else
                log "Theme updates available for $site_url:"
                echo "$theme_updates" | awk -F, 'NR>1 {print $1}' | while read -r theme; do
                    log "Updating theme: $theme"
                    run_as_user "wp theme update $theme --path=$wp_install_dir" "$username" "$wp_install_dir"
                done
            fi

            # Flush cache after updates
            run_as_user "wp cache flush --path=$wp_install_dir" "$username" "$wp_install_dir"
            log "Flushed cache for $site_url"
        fi
    fi
done < /etc/passwd

log "Finished checking and updating WordPress plugins and themes."