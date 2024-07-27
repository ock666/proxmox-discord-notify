#!/bin/bash

# Configuration
PROXMOX_API_URL="https://<your-proxmox-server-ip>:8006/api2/json/cluster/tasks"
PROXMOX_USERNAME="<your-username>@pam"
PROXMOX_PASSWORD="<your-password>"  # Replace with your actual password
DISCORD_WEBHOOK_URL="https://discordapp.com/api/webhooks/<webhook-id>/<webhook-token>"  # Replace with your Discord webhook URL
CHECK_INTERVAL=5  # Check every 60 seconds
TICKET_FILE="/tmp/proxmox_ticket.json"

# Function to send notification to Discord
send_discord_notification() {
    local message="$1"
    echo "Sending notification to Discord: $message"  # Debug
    curl -H "Content-Type: application/json" -d "$message" $DISCORD_WEBHOOK_URL
    echo "Notification sent."  # Debug
}

# Function to get a new PVE ticket
get_proxmox_ticket() {
    echo "Fetching new PVE ticket..."  # Debug
    response=$(curl -s -k -d "username=$PROXMOX_USERNAME&password=$PROXMOX_PASSWORD" $PROXMOX_API_URL/access/ticket)
    if [ $? -ne 0 ]; then
        echo "Failed to fetch ticket from Proxmox API."  # Debug
        exit 1
    fi
    echo "$response" > "$TICKET_FILE"
    echo "New ticket fetched."  # Debug
}

# Function to load the existing PVE ticket
load_ticket() {
    if [ -f "$TICKET_FILE" ]; then
        ticket_data=$(cat "$TICKET_FILE")
        TICKET=$(echo "$ticket_data" | jq -r '.data.ticket')
        CSRF_TOKEN=$(echo "$ticket_data" | jq -r '.data.CSRFPreventionToken')
    else
        get_proxmox_ticket
        load_ticket
    fi
}

# Function to remove old PVE ticket
remove_old_ticket() {
    echo "Removing old PVE ticket if it exists..."  # Debug
    rm -f "$TICKET_FILE"
    echo "Old ticket removed."  # Debug
}

# Function to check if the ticket is expired
check_ticket() {
    if [ -f "$TICKET_FILE" ]; then
        ticket_expired=false
        # Add logic to determine if the ticket is expired
        # For simplicity, we just check if the file exists
        if [ ! -s "$TICKET_FILE" ]; then
            ticket_expired=true
        fi
    else
        ticket_expired=true
    fi

    if [ "$ticket_expired" = true ]; then
        echo "Ticket expired or not found. Fetching a new ticket..."  # Debug
        get_proxmox_ticket
        load_ticket
    fi
}

# Remove old PVE ticket at the start
remove_old_ticket

# Send a test notification upon script start
test_message=$(cat <<EOF
{
    "content": "**Proxmox Task Notification Script Started**",
    "embeds": [{
        "title": "Test Notification",
        "description": "This is a test notification to confirm that the script is working correctly."
    }]
}
EOF
)
echo "Sending test notification..."  # Debug
send_discord_notification "$test_message"
echo "Test notification sent."  # Debug

# Main loop
while true; do
    check_ticket

    # Fetch tasks from Proxmox API
    echo "Fetching tasks from Proxmox API..."  # Debug
    response=$(curl -s -k -H "Authorization: PVEAuthCookie=$TICKET" -H "CSRFPreventionToken: $CSRF_TOKEN" $PROXMOX_API_URL)

    # Debugging response
    curl_exit_code=$?
    echo "Curl exit code: $curl_exit_code"  # Debug

    if [ $curl_exit_code -ne 0 ]; then
        echo "Curl error: $(curl -v -k -H "Authorization: PVEAuthCookie=$TICKET" -H "CSRFPreventionToken: $CSRF_TOKEN" $PROXMOX_API_URL 2>&1)"  # Debug
        echo "No response from API. Check your API URL and token."  # Debug
        sleep $CHECK_INTERVAL
        continue
    fi

    echo "API response: $response"  # Debug

    # Check if response is empty or has errors
    if [ -z "$response" ]; then
        echo "No response from API. Check your API URL and token."  # Debug
        sleep $CHECK_INTERVAL
        continue
    fi

    # Print the raw API response for inspection
    echo "Raw API response: $response"  # Debug

    # Parse the response and extract tasks
    tasks=$(echo $response | jq -r '.data[] | @base64')

    if [ -z "$tasks" ]; then
        echo "No tasks found in response."  # Debug
    else
        echo "Tasks found: $tasks"  # Debug
    fi

    # Convert tasks to a sortable format
    sortable_tasks=$(for task in $tasks; do
        task_start_time=$(echo ${task} | base64 --decode | jq -r '.starttime')
        echo "${task_start_time} ${task}" 
    done | sort -n | cut -d ' ' -f2-)

    # Store previously processed task IDs
    processed_task_ids=$(cat /tmp/processed_tasks.txt 2>/dev/null || echo "")

    for task in $sortable_tasks; do
        _jq() {
            echo ${task} | base64 --decode | jq -r ${1}
        }

        task_id=$(_jq '.upid')
        if echo "$processed_task_ids" | grep -q "$task_id"; then
            echo "Task ID $task_id already processed."  # Debug
            continue
        fi

        task_status=$(_jq '.status')
        task_start_time=$(_jq '.starttime')
        task_end_time=$(_jq '.endtime')
        task_node=$(_jq '.node')

        # Debug information for each task
        echo "Processing task ID: $task_id"  # Debug
        echo "Status: $task_status"  # Debug
        echo "Start Time: $task_start_time"  # Debug
        echo "End Time: $task_end_time"  # Debug
        echo "Node: $task_node"  # Debug

        # Convert the start and end times to human-readable format
        if [ "$task_start_time" != "null" ]; then
            start_time=$(date -d @$task_start_time +"%Y-%m-%d %H:%M:%S")
        else
            start_time="Unknown"
        fi
        if [ "$task_end_time" != "null" ]; then
            end_time=$(date -d @$task_end_time +"%Y-%m-%d %H:%M:%S")
        else
            end_time="Running"
        fi

        # Send a notification to Discord
        task_message=$(cat <<EOF
{
    "content": "**Proxmox Task Notification**",
    "embeds": [{
        "title": "Task ID: $task_id",
        "description": "Status: $task_status\nNode: $task_node\nStart Time: $start_time\nEnd Time: $end_time"
    }]
}
EOF
)
        echo "Sending notification for task ID: $task_id"  # Debug
        send_discord_notification "$task_message"
        echo "Notification for task ID: $task_id sent."  # Debug

        # Log the processed task ID
        echo "$task_id" >> /tmp/processed_tasks.txt
    done

    echo "Sleeping for $CHECK_INTERVAL seconds..."  # Debug
    # Sleep for the check interval
    sleep $CHECK_INTERVAL
done

