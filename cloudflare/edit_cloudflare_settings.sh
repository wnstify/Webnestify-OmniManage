#!/bin/bash

# Function to prompt for the Cloudflare API token
prompt_api_token() {
    echo -n "Please enter your Cloudflare API token: "
    read -r API_TOKEN
}

# Function to display the disclaimer and get confirmation
confirm_disclaimer() {
    echo "=================================================="
    echo "DISCLAIMER:"
    echo "This script will perform the following actions on"
    echo "all websites associated with the provided API token:"
    echo ""
    echo "1. Enable Bot Protection for all zones."
    echo "2. Flush all caches for all zones."
    echo "3. Add three basic page rules:"
    echo "   - Bypass cache for the entire site."
    echo "   - Bypass cache for all subdomains."
    echo "   - Cache everything for the /wp-content/uploads/ folder."
    echo ""
    echo "Additionally, this script will save all zone and website"
    echo "information to a .csv file for later use."
    echo ""
    echo "This will override settings on all websites from"
    echo "that particular API token."
    echo "Do you wish to continue?"
    echo "Type 'Y' to continue, 'N' to exit, or 'B' to go back."
    echo "=================================================="
    echo -n "Enter your choice [Y/N/B]: "
    read -r confirmation

    case "$confirmation" in
        Y|y)
            echo "Proceeding with the script..."
            ;;
        N|n)
            echo "Exiting script. No changes made."
            exit 0
            ;;
        B|b)
            echo "Going back to the previous menu."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter 'Y', 'N', or 'B'."
            confirm_disclaimer
            ;;
    esac
}

# Output CSV file for zones
OUTPUT_FILE="cloudflare_zones.csv"

# Function to fetch and save all zones to CSV
fetch_zones_to_csv() {
    echo "Fetching all zones from Cloudflare..."
    echo "id,name,status" > $OUTPUT_FILE

    page=1
    per_page=50

    while true; do
        echo "Fetching page $page..."
        zones=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?page=$page&per_page=$per_page" \
            -H "Authorization: Bearer $API_TOKEN" \
            -H "Content-Type: application/json")

        success=$(echo $zones | jq -r '.success')
        if [ "$success" != "true" ]; then
            echo "Failed to retrieve zones"
            exit 1
        fi

        count=$(echo $zones | jq -r '.result | length')
        echo $zones | jq -r '.result[] | [.id, .name, .status] | @csv' >> $OUTPUT_FILE

        if [ "$count" -lt "$per_page" ]; then
            break
        fi

        page=$((page + 1))
    done

    echo "All zones have been saved to $OUTPUT_FILE"
}

# Function to check if a page rule exists
check_page_rule_exists() {
    local zone_id=$1
    local target=$2

    existing_rule=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/pagerules" \
        -H "Authorization: Bearer $API_TOKEN" \
        -H "Content-Type: application/json" | jq -r --arg target "$target" '.result[] | select(.targets[].constraint.value == $target)')

    if [ -n "$existing_rule" ]; then
        return 0  # Rule exists
    else
        return 1  # Rule does not exist
    fi
}

# Function to create a page rule
create_page_rule() {
    local zone_id=$1
    local target=$2
    local cache_level=$3
    local security_level=$4
    local priority=$5

    if check_page_rule_exists $zone_id $target; then
        echo "Page rule for $target already exists in zone ID: $zone_id. Skipping."
    else
        response=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$zone_id/pagerules" \
            -H "Authorization: Bearer $API_TOKEN" \
            -H "Content-Type: application/json" \
            --data '{
                "targets": [
                    {
                        "target": "url",
                        "constraint": {
                            "operator": "matches",
                            "value": "'"$target"'"
                        }
                    }
                ],
                "actions": [
                    {
                        "id": "cache_level",
                        "value": "'"$cache_level"'"
                    },
                    {
                        "id": "security_level",
                        "value": "'"$security_level"'"
                    }
                ],
                "priority": '"$priority"',
                "status": "active"
            }')

        success=$(echo $response | jq -r '.success')

        if [ "$success" = "true" ]; then
            echo "Page rule created for $target in zone ID: $zone_id"
        else
            echo "Failed to create page rule for $target in zone ID: $zone_id"
            echo "Response: $response"
        fi
    fi
}

# Function to enable bot protection for a specific zone
enable_bot_protection() {
    local zone_id=$1

    response=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_id/bot_management" \
        -H "Authorization: Bearer $API_TOKEN" \
        -H "Content-Type: application/json" \
        --data-raw '{"fight_mode":true}')

    success=$(echo $response | jq -r '.success')

    if [ "$success" = "true" ]; then
        echo "Bot protection enabled for zone ID: $zone_id"
    else
        echo "Failed to enable bot protection for zone ID: $zone_id"
        echo "Response: $response"
    fi
}

# Function to flush cache for a specific zone
flush_cache() {
    local zone_id=$1

    response=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$zone_id/purge_cache" \
        -H "Authorization: Bearer $API_TOKEN" \
        -H "Content-Type: application/json" \
        --data '{"purge_everything":true}')

    success=$(echo $response | jq -r '.success')

    if [ "$success" = "true" ]; then
        echo "Cache flushed for zone ID: $zone_id"
    else
        echo "Failed to flush cache for zone ID: $zone_id"
        echo "Response: $response"
    fi
}

# Main execution flow
prompt_api_token  # Prompt the user for the Cloudflare API token
confirm_disclaimer  # Confirm the disclaimer before proceeding
fetch_zones_to_csv  # Fetch and save zone information to CSV

# Read CSV file and perform operations for each zone
tail -n +2 $OUTPUT_FILE | while IFS=, read -r id name status; do
    # Remove quotes from id and name if they exist
    id=$(echo $id | tr -d '"')
    name=$(echo $name | tr -d '"')

    echo "Processing zone: $name (ID: $id)"

    # Create specific page rules if they don't already exist
    create_page_rule $id "https://$name/*" "bypass" "high" 1
    create_page_rule $id "https://*.$name/*" "bypass" "high" 2
    create_page_rule $id "https://$name/wp-content/uploads*" "cache_everything" "high" 3

    # Enable bot protection for the zone
    enable_bot_protection $id

    # Flush cache for the zone
    flush_cache $id
done

echo "All operations completed for all zones."
