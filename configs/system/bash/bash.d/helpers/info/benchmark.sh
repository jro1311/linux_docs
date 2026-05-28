# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

benchmark() {
    local start_ns end_ns delta_ns

    start_ns=$(date +%s%N)
    "$@"
    end_ns=$(date +%s%N)
    delta_ns=$(( end_ns - start_ns ))

    blue_message "Time:" "$((delta_ns/1000000)) ms"
}

benchmark_avg() {
    local cmd=$1
    local runs=$2
    local i=1
    local total_ns=0
    local start_ns end_ns delta_ns

    while [ "$i" -le "$runs" ]; do
        start_ns=$(date +%s%N)
        "$cmd"
        end_ns=$(date +%s%N)
        delta_ns=$(( end_ns - start_ns ))
        total_ns=$(( total_ns + delta_ns ))
        i=$(( i + 1 ))
    done

    local avg_ns=$(( total_ns / runs ))

    blue_message "Time (Average):" "$((avg_ns/1000000)) ms ($runs runs)"
}
