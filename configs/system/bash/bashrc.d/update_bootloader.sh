# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

update_grub() {
    local updating="$1"
    if command -v update-grub >/dev/null 2>&1; then
        echo "$updating"
        sudo update-grub

    elif command -v grub2-mkconfig >/dev/null 2>&1; then
        echo "$updating"
        sudo grub2-mkconfig -o /boot/grub2/grub.cfg

    elif command -v grub-mkconfig >/dev/null 2>&1; then
        echo "$updating"
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi
}

update_limine() {
    local updating="$1"
    if command -v limine-update >/dev/null 2>&1; then
        echo "$updating"
        sudo limine-update
    fi
}

update_systemd_boot() {
    local updating="$1"
    if find /boot/efi/EFI -name "*systemd-boot*.efi" >/dev/null 2>&1; then
        echo "$updating"
        sudo bootctl update
    fi
}

update_bootloader() {
    local loaders=(grub limine systemd-boot)

    for loader in "${loaders[@]}"; do
        local updating="${green}Updating $loader... ${reset}"

        case "$loader" in
            "grub")
                update_grub "$updating"
                ;;
            "limine")
                update_limine "$updating"
                ;;
            "systemd-boot")
                update_systemd_boot "$updating"
                ;;
        esac
    done
}
