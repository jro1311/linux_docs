# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

benchmark() {
    local start_ns end_ns delta_ns

    start_ns=$(date +%s%N)
    "$@"
    end_ns=$(date +%s%N)

    delta_ns=$(( end_ns - start_ns ))

    blue_message "Time:" "$(format_nanoseconds "$delta_ns")"
}

benchmark_avg() {
    local runs=$1
    shift
    local total_ns=0 i=1 start_ns end_ns delta_ns avg_ns

    while [ "$i" -le "$runs" ]; do
        start_ns=$(date +%s%N)
        "$@"
        end_ns=$(date +%s%N)

        total_ns=$(( total_ns + (end_ns - start_ns) ))
        i=$(( i + 1 ))
    done

    avg_ns=$(( total_ns / runs ))
    blue_message "Time (Average):" "$(format_nanoseconds "$avg_ns") ($runs runs)"
}

determine_compression_algorithm() {
    [ -n "${comp_algo_initialized:-}" ] && return 0

    blue_message "Calculating:" "Optimal compression algorithm..."

    local zstd_speed_raw zstd_speed

    zstd_speed_raw=$(zstd -b --fast=1 2>/dev/null \
        | grep -oE '[0-9]+\.[0-9]+ MB/s' \
        | head -n1 \
    )

    zstd_speed=${zstd_speed_raw%%.*}

    if [ -n "$zstd_speed" ]; then
        blue_message "Benchmark (zstd -b --fast=1):" "${zstd_speed} MB/s"
    fi

    if [ -n "$zstd_speed" ] && [ "$zstd_speed" -ge 200 ]; then
        comp_algo="zstd"
    else
        comp_algo="lz4"
    fi

    comp_algo_initialized=1
}

determine_network_speeds() {
    [ -n "${net_speeds_initialized:-}" ] && return 0

    if ! command -v speedtest-cli >/dev/null 2>&1; then
        red_message "Error:" "speedtest-cli not detected."
        return 1
    fi

    blue_message "Calculating:" "Network speeds..."

    local out down_raw up_raw down_i up_i diff

    out=$(speedtest-cli)

    if [ -z "$out" ]; then
        red_message "Error:" "No output from speedtest."
        return 1
    fi

    down_raw=$(printf "%s" "$out" | awk '/Download:/ {print $2}')
    up_raw=$(printf "%s" "$out" | awk '/Upload:/ {print $2}')

    down_i=${down_raw%%.*}
    up_i=${up_raw%%.*}

    # Round to the nearest 10
    download_speed_mb=$(( (down_i + 5) / 10 * 10 ))
    upload_speed_mb=$(( (up_i + 5) / 10 * 10 ))

    # Equalize if difference is 10 or less
    diff=$(( download_speed_mb - upload_speed_mb ))
    if [ ${diff#-} -le 10 ]; then
        if [ "$download_speed_mb" -ge "$upload_speed_mb" ]; then
            upload_speed_mb=$download_speed_mb
        else
            download_speed_mb=$upload_speed_mb
        fi
    fi

    [ "$download_speed_mb" -eq 0 ] && download_speed_mb=5
    [ "$upload_speed_mb" -eq 0 ] && upload_speed_mb=5

    net_speeds_initialized=1
}
