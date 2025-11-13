#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Define the operating system and convert it to lowercase
if [ -f /etc/os-release ]; then
    . /etc/os-release

    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"

    os="${os,,}"
    os_like="${os_like,,}"

    if [ "$os_like" != "$os" ]; then
        echo "${green}Base Distro(s): $os_like ${reset}"
    fi

    echo "${green}Distro: $os ${reset}"

    debian_version="0"
    ubuntu_version="0"
    linuxmint_version="0"
    fedora_version="0"
    openmandriva_version="0"
    opensuse_version="0"

    case "$os" in
        "debian")
            debian_version="${VERSION_ID:-0}"
            echo "${green}Distro Version: $debian_version ${reset}"
            ;;
        "ubuntu")
            ubuntu_version="${VERSION_ID:-0}"
            echo "${green}Distro Version: $ubuntu_version ${reset}"
            ;;
        "linuxmint")
            linuxmint_version="${VERSION_ID:-0}"
            echo "${green}Distro Version: $linuxmint_version ${reset}"
            ;;
        "fedora")
            fedora_version="${VERSION_ID:-0}"
            echo "${green}Distro Version: $fedora_version ${reset}"
            ;;
        "openmandriva")
            openmandriva_version="${VERSION_ID:-0}"
            echo "${green}Distro Version: $openmandriva_version ${reset}"
            ;;
        "opensuse-leap")
            opensuse_version="${VERSION_ID:-0}"
            echo "${green}Distro Version: $opensuse_version ${reset}"
            ;;
        *)
            case "$os_like" in
                "debian")
                    debian_version="${VERSION_ID:-0}"
                    echo "${green}Base Version: $debian_version ${reset}"
                    ;;
                "ubuntu debian")
                    ubuntu_version="${VERSION_ID:-0}"
                    echo "${green}Base Version: $ubuntu_version ${reset}"
                    ;;
                "fedora")
                    fedora_version="${VERSION_ID:-0}"
                    echo "${green}Base Version: $fedora_version ${reset}"
                    ;;
            esac
            ;;
    esac
else
    echo "${red}Unable to detect the operating system. ${reset}"
    exit 1
fi

# Define package managers
primary_package_manager="unknown"
secondary_package_manager="unknown"

primary_package_managers=(apt dnf eopkg pacman xbps-install zypper rpm-ostree)
secondary_package_managers=(nala paru yay)

for cmd in "${primary_package_managers[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        primary_package_manager="$cmd"
        break
    fi
done

for cmd in "${secondary_package_managers[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        secondary_package_manager="$cmd"
        break
    fi
done

if [ "$primary_package_manager" = "xbps-install" ]; then
    primary_package_manager="xbps"
fi

if [ "$primary_package_manager" != "unknown" ]; then
    echo "${green}Primary Package Manager: $primary_package_manager ${reset}"
fi

if [ "$secondary_package_manager" != "unknown" ]; then
    echo "${green}Secondary Package Manager: $secondary_package_manager ${reset}"
fi

# Define bootloader
bootloader="unknown"
update_bootloader="unknown"

if command -v update-grub > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="update-grub"

elif command -v grub2-mkconfig > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="grub2-mkconfig -o /boot/grub2/grub.cfg"

elif command -v grub-mkconfig > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="grub-mkconfig -o /boot/grub/grub.cfg"

elif command -v limine-update > /dev/null 2>&1; then
    bootloader="limine"
    update_bootloader="limine-update"

elif find /boot/efi/EFI -name "*systemd-boot*.efi" > /dev/null 2>&1; then
    bootloader="systemd-boot"
    update_bootloader="bootctl update"
fi

if [ "$bootloader" != "unknown" ]; then
    echo "${green}Bootloader: $bootloader ${reset}"
fi

# List of packages
packages=("corectrl")

# Checks for package manager and installs package(s)
case "$primary_package_manager" in
    "apt")
        sudo apt-get install -y "${packages[@]}"
        ;;
    "dnf")
        sudo dnf install -y "${packages[@]}"
        ;;
    "eopkg")
        sudo eopkg install -y "${packages[@]}"
        ;;
    "pacman")
        sudo pacman -S --needed --noconfirm "${packages[@]}"
        ;;
    "xbps")
        sudo xbps-install -Sy "${packages[@]}"
        ;;
    "zypper")
        case "$os" in
            "opensuse-tumbleweed")
                sudo zypper addrepo https://download.opensuse.org/repositories/home:Dead_Mozay/openSUSE_Tumbleweed/home:Dead_Mozay.repo
                sudo zypper in -y "${packages[@]}"
                ;;
            "opensuse-slowroll")
                sudo zypper addrepo https://download.opensuse.org/repositories/home:Dead_Mozay/openSUSE_Slowroll/home:Dead_Mozay.repo
                sudo zypper in -y "${packages[@]}"
                ;;
            *)
                echo "${red}Unsupported operating system. ${reset}"
                exit 1
                ;;
        esac
        ;;
    "rpm-ostree")
        if ! command -v "${packages[@]}" > /dev/null 2>&1; then
            sudo rpm-ostree install "${packages[@]}"
            echo "${green}Reboot and run script again to complete. ${reset}"
            exit 0
        fi
        ;;
    *)
        echo "${red}Unsupported package manager. ${reset}"
        exit 1
        ;;
esac


# Get the current user's primary group
group=$(id -gn)

# Creates a polkit rule file with the current user's primary group
sudo tee /etc/polkit-1/rules.d/90-corectrl.rules << EOF
polkit.addRule(function(action, subject) {
    if ((action.id == 'org.corectrl.helper.init' ||
        action.id == 'org.corectrl.helperkiller.init') &&
        subject.local == true &&
        subject.active == true &&
        subject.isInGroup("$group")) {
            return polkit.Result.YES;
    }
});
EOF

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Kernel argument(s)
gpu_karg="amdgpu.ppfeaturemask=0xffffffff"

# Checks for AMD GPU
if echo "$gpu_info" | grep -Fiq "amd"; then
    echo "${green}Detected GPU: AMD ${reset}"

    # Checks for package manager or bootloader, then adds kernel argument(s)
    case "$primary_package_manager" in
        "rpm-ostree")
            if ! rpm-ostree kargs | grep -Fq "$gpu_karg"; then
                sudo rpm-ostree kargs --append="$gpu_karg"
                echo "${green}'$gpu_karg' added to kernel arguments. ${reset}"

            else
                echo "${green}'$gpu_karg' is already part of kernel arguments. ${reset}"
            fi
            ;;
        *)
            case "$bootloader" in
                "grub")
                    if ! grep -Fq "$gpu_karg" /etc/default/grub; then
                        sudo sed -i "s/\(GRUB_CMDLINE_LINUX=\"[^\"]*\)\"/\1 $gpu_karg\"/" /etc/default/grub
                        sudo bash -c "$update_bootloader"
                        echo "${green}'$gpu_karg' added to kernel arguments. ${reset}"

                    else
                        echo "${green}'$gpu_karg' is already part of kernel arguments. ${reset}"
                    fi
                    ;;
                "limine")
                    if ! grep -Fq "$gpu_karg" /etc/default/limine; then
                        sudo sed -i "/^KERNEL_CMDLINE\[default\\]/ s/\"$/ $gpu_karg\"/" /etc/default/limine
                        sudo bash -c "$update_bootloader"
                        echo "${green}'$gpu_karg' added to kernel arguments. ${reset}"

                    else
                        echo "${green}'$gpu_karg' is already part of kernel arguments. ${reset}"
                    fi
                    ;;
            esac
            ;;
    esac

else
    echo "${yellow}No AMD GPU detected. ${reset}"
fi

# Adds package(s) to autostart
mkdir -pv "$HOME/.config/autostart"
cp -v /usr/share/applications/org.corectrl.*.desktop "$HOME/.config/autostart/org.corectrl.CoreCtrl.desktop"

# Prints a conclusive message
echo "${green}CoreCtrl is now installed. ${reset}"
