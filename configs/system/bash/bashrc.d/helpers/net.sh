# shellcheck shell=bash
# shellcheck source=/dev/null
# shellcheck disable=SC2034,SC2154

get_location() {
    local file="$HOME/.config/net/location.conf"

    if [ -f "$file" ]; then
        . "$file"
        latitude="${lat:-}"
        longitude="${lon:-}"

        if [ -z "$latitude" ] || [ -z "$longitude" ]; then
            red_message "Error:" "Failed to get coordinates from local file."
            return 1
        fi
    else
        local location
        location=$(curl -sS http://ip-api.com/json) || return 1

        if ! echo "$location" | jq empty >/dev/null 2>&1; then
            red_message "Error:" "Invalid JSON from API."
            return 1
        fi

        latitude=$(echo "$location" | jq -r '.lat')
        longitude=$(echo "$location" | jq -r '.lon')

        if [ "$latitude" = "null" ] || [ "$longitude" = "null" ]; then
            red_message "Error:" "Failed to get coordinates from API."
            return 1
        fi

        mkdir -p "$HOME/.config/net" || return 1

        {
            echo "lat=$latitude"
            echo "lon=$longitude"
        } > "$file" || return 1
    fi
}
