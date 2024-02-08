#!/bin/bash

app_startup="Started app-flatpak-com.google"
app_shutdown="google.Chrome-[0-9]\+.scope: Consumed"

start_time=""
end_time=""

# Function to extract timestamp from log line
get_timestamp() {
    awk '{print $3}'
}

# Continuously monitor syslog for events
tail -n 0 -F /var/log/syslog | while read line; do
    if grep -q "$app_startup" <<< "$line"; then
        start_time=$(get_timestamp <<< "$line")
    elif grep -q "$app_shutdown" <<< "$line"; then
        end_time=$(get_timestamp <<< "$line")

        # Process events
        if [ -n "$start_time" ] && [ -n "$end_time" ]; then
            unix_start_time=$(date -d "$start_time" +%s)
            unix_end_time=$(date -d "$end_time" +%s)

            elapsed_seconds=$((unix_end_time - unix_start_time))

            elapsed_hours=$((elapsed_seconds / 3600))
            elapsed_minutes=$(( (elapsed_seconds % 3600) / 60 ))
            elapsed_seconds=$((elapsed_seconds % 60))
            
            notify-send "Elapsed time: $elapsed_hours hours, $elapsed_minutes minutes, $elapsed_seconds seconds"

            # Reset variables for next iteration
            start_time=""
            end_time=""
        fi
    fi
done
