#!/bin/bash

# Define the log file location
LOG_FILE="webnestify_omnimanage.log"

# Function to log actions and outputs
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to execute scripts and log their output
execute_script() {
    log "Executing: $1"
    bash "$1" 2>&1 | tee -a "$LOG_FILE"
    log "Completed: $1"
}

# Function to display the welcome screen
function welcome_screen() {
    clear
    log "Displaying Welcome Screen"
    echo "============================================"
    echo "            Webnestify OmniManage           "
    echo "============================================"
    echo
    echo "Managing your WordPress, Cloudflare, and"
    echo "server settings has never been easier."
    echo
    echo "Please choose an option to proceed:"
    echo "1) Manage WordPress Sites"
    echo "2) Manage Cloudflare Settings"
    echo "3) System Maintenance"
    echo "4) Exit"
    echo
    echo -n "Enter your choice [1-4]: "
}

# Function to manage WordPress based on the platform (Enhance or Runcloud)
function manage_wordpress() {
    while true; do
        echo "Choose the platform:"
        echo "1) Enhance"
        echo "2) Runcloud"
        echo "3) Go Back"
        echo -n "Enter your choice [1-4]: "
        read -r wp_platform
        log "Selected WordPress Platform Option: $wp_platform"
        case $wp_platform in
            1)
                while true; do
                    echo "Managing WordPress on Enhance..."
                    echo "1) Check WordPress Checksums"
                    echo "2) Update Plugins & Themes"
                    echo "3) Update WP Memory Limit"
                    echo "4) Go Back"
                    echo -n "Enter your choice [1-4]: "
                    read -r wp_enhance_choice
                    log "Selected Enhance Option: $wp_enhance_choice"
                    case $wp_enhance_choice in
                        1) execute_script "wordpress/enhance/check_wp_checksums-enhance.sh" ;;
                        2) execute_script "wordpress/enhance/update_wp_plugins_themes-enhance.sh" ;;
                        3) execute_script "wordpress/enhance/update_wp_memory_limit-enhance.sh" ;;
                        4) break ;;
                        *) echo "Invalid option. Please try again." ;;
                    esac
                done
                ;;
            2)
                while true; do
                    echo "Managing WordPress on Runcloud..."
                    echo "1) Check WordPress Checksums"
                    echo "2) Update Plugins & Themes"
                    echo "3) Update WP Memory Limit"
                    echo "4) Go Back"
                    echo -n "Enter your choice [1-4]: "
                    read -r wp_runcloud_choice
                    log "Selected Runcloud Option: $wp_runcloud_choice"
                    case $wp_runcloud_choice in
                        1) execute_script "wordpress/runcloud/check_wp_checksums-runcloud.sh" ;;
                        2) execute_script "wordpress/runcloud/update_wp_plugins_themes-runcloud.sh" ;;
                        3) execute_script "wordpress/runcloud/update_wp_memory_limit-runcloud.sh" ;;
                        4) break ;;
                        *) echo "Invalid option. Please try again." ;;
                    esac
                done
                ;;
            3) break ;;
            *) echo "Invalid platform choice. Please try again." ;;
        esac
    done
}

# Function to execute the user's choice
function execute_choice() {
    log "Main Menu Choice: $1"
    case $1 in
        1)
            manage_wordpress
            ;;
        2)
            while true; do
                echo "Managing Cloudflare Settings..."
                echo "1) Edit Cloudflare Settings"
                echo "2) Go Back"
                echo -n "Enter your choice [1-2]: "
                read -r cloudflare_choice
                log "Selected Cloudflare Option: $cloudflare_choice"
                case $cloudflare_choice in
                    1) execute_script "cloudflare/edit_cloudflare_settings.sh" ;;
                    2) break ;;
                    *) echo "Invalid option. Please try again." ;;
                esac
            done
            ;;
        3)
            while true; do
                echo "System Maintenance..."
                echo "1) Check All Crontabs"
                echo "2) Check Running Processes"
                echo "3) Check Processes with Open Ports"
                echo "4) Check System Updates"
                echo "5) Go Back"
                echo -n "Enter your choice [1-4]: "
                read -r sys_choice
                log "Selected System Maintenance Option: $sys_choice"
                case $sys_choice in
                    1) execute_script "system/check_all_crons.sh" ;;
                    2) execute_script "system/check_running_processes.sh" ;;
                    3) execute_script "system/check_processes_with_ports.sh" ;;
                    4) execute_script "system/check_and_update_system.sh" ;;
                    5) break ;;
                    *) echo "Invalid option. Please try again." ;;
                esac
            done
            ;;
        4)
            log "Exiting Webnestify OmniManage"
            echo "Exiting Webnestify OmniManage. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
}

# Main loop to display the menu and handle user input
while true; do
    welcome_screen
    read -r choice
    log "User Input Choice: $choice"
    execute_choice "$choice"
    echo
    echo "Press Enter to continue..."
    read -r
done
