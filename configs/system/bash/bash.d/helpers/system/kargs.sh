#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_kernel_parameter_exists() {
    local karg="$1"

    case "$primary_pm" in
        rpm-ostree)
            rpm-ostree kargs | grep -Fq "$karg"
            ;;
        *)
            case "$bootloader" in
                "grub")
                    grep -Fq "$karg" /etc/default/grub
                    ;;
                "limine")
                    grep -Fq "$karg" /etc/default/limine
                    ;;
                *)
                    unsupported_bootloader
                    return 1
            esac
            ;;
    esac
}

_kernel_parameter_append() {
    local karg="$1"

    case "$primary_pm" in
        rpm-ostree)
            sudo rpm-ostree kargs --append="$karg"
            ;;
        *)
            case "$bootloader" in
                "grub")
                    sudo sed -i "s/\(GRUB_CMDLINE_LINUX=\"[^\"]*\)\"/\1 $karg\"/" /etc/default/grub
                    ;;
                "limine")
                    sudo sed -i "/^KERNEL_CMDLINE\[default\\]/ s/\"$/ $karg\"/" /etc/default/limine
                    ;;
                *)
                    unsupported_bootloader
                    return 1
            esac
            ;;
    esac
}

add_kernel_parameter() {
    assert_arity "$#" "ge" 1 "<parameter>" || return 1
    detect_system

    local updated=0

    for karg in "$@"; do
        if _kernel_parameter_exists "$karg"; then
            continue
        fi

        if _kernel_parameter_append "$karg"; then
            green_message "Success:" "'$karg' added to kernel parameters."
            updated=1
        else
            red_message "Error:" "Failed to add '$karg'."
            return 1
        fi
    done

    if [ "$updated" -eq 1 ] && [ "$primary_pm" != "rpm-ostree" ]; then
        update_bootloader
    fi
}

_kernel_parameter_delete() {
    local karg="$1"

    case "$primary_pm" in
        rpm-ostree)
            sudo rpm-ostree kargs --delete="$karg"
            ;;
        *)
            case "$bootloader" in
                "grub")
                    sudo sed -i -e "s/$karg//g" -e 's/ *"$/"/' /etc/default/grub
                    ;;
                "limine")
                    sudo sed -i -e "s/$karg//g" -e 's/ *"$/"/' /etc/default/limine
                    ;;
                *)
                    unsupported_bootloader
                    return 1
            esac
            ;;
    esac
}

remove_kernel_parameter() {
    assert_arity "$#" "ge" 1 "<parameter>" || return 1
    detect_system

    local updated=0

    for karg in "$@"; do
        if ! _kernel_parameter_exists "$karg"; then
            continue
        fi

        if _kernel_parameter_delete "$karg"; then
            green_message "Success:" "'$karg' removed from kernel parameters."
            updated=1
        else
            red_message "Error:" "Failed to remove '$karg'."
            return 1
        fi
    done

    if [ "$updated" -eq 1 ] && [ "$primary_pm" != "rpm-ostree" ]; then
        update_bootloader
    fi
}
