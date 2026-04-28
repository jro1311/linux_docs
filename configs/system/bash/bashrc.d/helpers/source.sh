# shellcheck shell=bash
# shellcheck source=/dev/null

# fast_source() {
#     shopt -s globstar nullglob 2>/dev/null || return 1
#
#     local base=$1
#     local rc
#
#
#     # # Source base-level .sh files
#     # for rc in "$base"/*.sh; do
#     #     [ -e "$rc" ] || continue
#     #     . "$rc"
#     # done
#     #
#     # # Source recursive .sh files
#     # for rc in "$base"/**/*.sh; do
#     #     [ -e "$rc" ] || continue
#     #     . "$rc"
#     # done
# }
#
# safe_source() {
#     local base=$1
#     local rc
#
#     for rc in "$base"/*.sh; do
#         [ -e "$rc" ] || continue
#         . "$rc"
#     done
#
#     for rc in "$base/helpers"/*.sh; do
#         [ -e "$rc" ] || continue
#         . "$rc"
#     done
#
#     for rc in "$base/install_packages"/*.sh; do
#         [ -e "$rc" ] || continue
#         . "$rc"
#     done
#
#     for rc in "$base/configure_packages"/*.sh; do
#         [ -e "$rc" ] || continue
#         . "$rc"
#     done
# }
