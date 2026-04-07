# shellcheck shell=bash
# shellcheck source=/dev/null
# shellcheck disable=SC2034,SC2154

get_location() {
    if [ -f "$HOME/Documents/location_info.conf" ]; then
        source "$HOME/Documents/location_info.conf"
        latitude="$lat"
        longitude="$long"
    else
        location=$(curl -sS http://ip-api.com/json)
        latitude=$(echo "$location" | jq -r '.lat')
        longitude=$(echo "$location" | jq -r '.lon')

        if [ "$latitude" = "null" ] || [ "$longitude" = "null" ]; then
            red_message "Error:" "Failed to get coordinates."
            exit 1
        fi

        {
            echo "lat=$latitude"
            echo "long=$longitude"
        } > "$HOME/Documents/location_info.conf"
    fi
}
