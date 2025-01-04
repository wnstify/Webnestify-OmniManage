#!/bin/bash

# Generate a log file name with the current date and time
LOG_FILE="update_wp_plugins_themes_$(date +'%Y-%m-%d_%H-%M-%S').log"

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
    echo "This script will check and update all WordPress"
    echo "plugins and themes for installations found in"
    echo "/home/*/webapps/*."
    echo ""
    echo "Do you wish to continue?"
    echo "Type 'Y' to continue, 'N' to exit."
    echo "=================================================="
    echo -n "Enter your choice [Y/N]: "
    read -r confirmation

    case "$confirmation" in
        Y|y)
            echo "Proceeding with the WordPress plugin and theme update..."
            log "User confirmed to proceed with WordPress plugin and theme update."
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

log "Starting WordPress plugin and theme update process..."

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
                        site_url=$(run_as_user "wp option get home --path=${wp_install_dir}" "$user" "$wp_install_dir")
                        if [ $? -ne 0 ]; then
                            log "Error retrieving site URL for $user at $wp_install_dir"
                            continue
                        fi

                        # Check for plugin updates
                        plugin_updates=$(run_as_user "wp plugin list --update=available --path=${wp_install_dir} --format=csv" "$user" "$wp_install_dir")
                        if [[ -z "$plugin_updates" || "$plugin_updates" == "Plugin" ]]; then
                            log "No plugin updates available for $site_url"
                        else
                            log "Plugin updates available for $site_url:"
                            echo "$plugin_updates" | awk -F, 'NR>1 {print $1}' | while read plugin; do
                                log "Updating plugin: $plugin"
                                run_as_user "wp plugin update $plugin --path=${wp_install_dir}" "$user" "$wp_install_dir"
                            done
                        fi

                        # Check for theme updates
                        theme_updates=$(run_as_user "wp theme list --update=available --path=${wp_install_dir} --format=csv" "$user" "$wp_install_dir")
                        if [[ -z "$theme_updates" || "$theme_updates" == "Theme" ]]; then
                            log "No theme updates available for $site_url"
                        else
                            log "Theme updates available for $site_url:"
                            echo "$theme_updates" | awk -F, 'NR>1 {print $1}' | while read theme; do
                                log "Updating theme: $theme"
                                run_as_user "wp theme update $theme --path=${wp_install_dir}" "$user" "$wp_install_dir"
                            done
                        fi

                        # Flush cache after updates
                        run_as_user "wp cache flush --path=${wp_install_dir}" "$user" "$wp_install_dir"
                        log "Flushed cache for $site_url"
                    fi
                fi
            done
        fi
    fi
done < /etc/passwd

log "Finished checking and updating WordPress plugins and themes."
