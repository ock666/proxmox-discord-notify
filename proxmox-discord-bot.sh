#!/bin/bash

# secrets
. .env
# Configuration
. config

# Function to send notification to Discord
send_discord_notification() {
    local message="$1"
    echo "$(date): Sending notification to Discord: $message"
    curl -H "Content-Type: application/json" -d "$message" "$DISCORD_WEBHOOK_URL"
    echo "$(date): Notification sent."
}

# Function to check if a task has been sent
task_already_sent() {
    local task_id="$1"
    if grep -q "$task_id" "$SENT_TASKS_FILE"; then
        return 0
    else
        return 1
    fi
}

# Function to mark a task as sent
mark_task_as_sent() {
    local task_id="$1"
    echo "$task_id" >> "$SENT_TASKS_FILE"
}

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
echo "$(date): Sending test notification..."
send_discord_notification "$test_message"
echo "$(date): Test notification sent."

# Main loop
while true; do
    # Fetch tasks from Proxmox API
    echo "$(date): Fetching tasks from Proxmox API..."
    response=$(curl -s -k -H "Authorization: $PROXMOX_API_KEY" "$PROXMOX_API_URL")

    # Debugging response
    curl_exit_code=$?
    echo "$(date): Curl exit code: $curl_exit_code"

    if [ $curl_exit_code -ne 0 ]; then
        echo "$(date): Curl error: $(curl -v -k -H "Authorization: $PROXMOX_API_KEY" "$PROXMOX_API_URL" 2>&1)"
        echo "$(date): No response from API. Check your API URL and token."
        sleep "$CHECK_INTERVAL"
        continue
    fi

    echo "$(date): API response: $response"

    # Check if response is empty or has errors
    if [ -z "$response" ]; then
        echo "$(date): No response from API. Check your API URL and token."
        sleep "$CHECK_INTERVAL"
        continue
    fi

    # Print the raw API response for inspection
    echo "$(date): Raw API response: $response"

    # Parse the response and extract tasks
    tasks=$(echo "$response" | jq -r '.data[] | @base64')

    if [ -z "$tasks" ]; then
        echo "$(date): No tasks found in response."
    else
        echo "$(date): Tasks found: $tasks"
    fi

    for task in $tasks; do
        _jq() {
            echo "${task}" | base64 --decode | jq -r "${1}"
        }

        task_status=$(_jq '.status')
        task_id=$(_jq '.upid')
        task_start_time=$(_jq '.starttime')
        task_end_time=$(_jq '.endtime')
        task_node=$(_jq '.node')

        # Debug information for each task
        echo "$(date): Processing task ID: $task_id"
        echo "$(date): Status: $task_status"
        echo "$(date): Start Time: $task_start_time"
        echo "$(date): End Time: $task_end_time"
        echo "$(date): Node: $task_node"

        # Check if task has already been sent
        if task_already_sent "$task_id"; then
            echo "$(date): Task ID $task_id has already been sent. Skipping..."
            continue
        fi

        # Convert the start and end times to human-readable format
        start_time=$(date -d @"$task_start_time" +"%Y-%m-%d %H:%M:%S")
        if [ "$task_end_time" != "null" ]; then
            end_time=$(date -d @"$task_end_time" +"%Y-%m-%d %H:%M:%S")
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
        echo "$(date): Sending notification for task ID: $task_id"
        send_discord_notification "$task_message"
        mark_task_as_sent "$task_id"
        echo "$(date): Notification for task ID: $task_id sent."
    done

    echo "$(date): Sleeping for $CHECK_INTERVAL seconds..."
    # Sleep for the check interval
    sleep "$CHECK_INTERVAL"
done

