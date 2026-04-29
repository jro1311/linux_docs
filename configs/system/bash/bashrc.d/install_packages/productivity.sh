# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_install_brave_fallback() {
    if [ "$flatpak_installed" -eq 1 ]; then
        install_flatpak_pkg_bypass "com.brave.Browser"

    elif [ "$snap_installed" -eq 1 ]; then
        sudo snap install brave
    else
        unsupported_package_manager
        return 1
    fi
}

install_brave() {
    detect_system
    local installed=0

    case "$primary_pm" in
        rpm-ostree) ;;
        *) curl -fsS https://dl.brave.com/install.sh | sh && installed=1 ;;
    esac

    if [ "$installed" -eq 0 ]; then
        _install_brave_fallback
    fi
}

_install_librewolf_apt() {
    sudo apt-get install -y extrepo || return 1
    sudo extrepo enable librewolf || return 1
    sudo apt-get update || return 1
    sudo apt-get install -y librewolf || return 1
}

_install_librewolf_dnf() {
    curl -fsSL https://repo.librewolf.net/librewolf.repo | pkexec tee /etc/yum.repos.d/librewolf.repo || return 1
    sudo dnf install -y librewolf || return 1
}

_install_librewolf_pacman() {
    install_aur_pkg_bypass "librewolf-bin" || return 1
}

_install_librewolf_fallback() {
    if [ "$flatpak_installed" -eq 1 ]; then
        install_flatpak_pkg_bypass "io.gitlab.librewolf-community"
    else
        unsupported_package_manager
        return 1
    fi
}

install_librewolf() {
    detect_system
    case "$primary_pm" in
        apt)    _install_librewolf_apt ;;
        dnf)    _install_librewolf_dnf ;;
        pacman) _install_librewolf_pacman ;;
        *)      _install_librewolf_fallback ;;
    esac
}

_install_ungoogled_chromium_dnf() {
    sudo dnf copr enable -y wojnilowicz/ungoogled-chromium || return 1
    sudo dnf install -y ungoogled-chromium || return 1
}

_install_ungoogled_chromium_pacman() {
    install_aur_pkg_bypass "ungoogled-chromium-bin" || return 1
}

_install_ungoogled_chromium_fallback() {
    if [ "$flatpak_installed" -eq 1 ]; then
        install_flatpak_pkg_bypass "io.github.ungoogled_software.ungoogled_chromium"
    else
        unsupported_package_manager
        return 1
    fi
}

install_ungoogled_chromium() {
    detect_system
    case "$primary_pm" in
        dnf)    _install_ungoogled_chromium_dnf ;;
        pacman) _install_ungoogled_chromium_pacman ;;
        *)      _install_ungoogled_chromium_fallback ;;
    esac
}

_install_onlyoffice_apt() {
    local deb="$HOME/Downloads/onlyoffice.deb" || return 1
    wget -O "$deb" https://github.com/ONLYOFFICE/DesktopEditors/releases/latest/download/onlyoffice-desktopeditors_amd64.deb || return 1
    sudo apt-get install -y "$deb" || return 1
    rm -f "$deb"
}

_install_onlyoffice_dnf() {
    local rpm="$HOME/Downloads/onlyoffice.rpm" || return 1
    wget -O "$rpm" https://github.com/ONLYOFFICE/DesktopEditors/releases/latest/download/onlyoffice-desktopeditors_amd64.rpm || return 1
    sudo apt-get install -y "$rpm" || return 1
    rm -f "$rpm"
}

_install_onlyoffice_pacman() {
    enable_chaotic_aur || return 1
    install_aur_pkg_bypass "onlyoffice-bin" || return 1
}

_install_onlyoffice_fallback() {
    if [ "$flatpak_installed" -eq 1 ]; then
        install_flatpak_pkg_bypass "org.onlyoffice.desktopeditors"

    elif [ "$snap_installed" -eq 1 ]; then
        sudo snap install onlyoffice-desktopeditors
    else
        unsupported_package_manager
        return 1
    fi
}

install_onlyoffice() {
    detect_system
    case "$primary_pm" in
        apt)    _install_onlyoffice_apt ;;
        dnf)    _install_onlyoffice_dnf ;;
        pacman) _install_onlyoffice_pacman ;;
        *)      _install_onlyoffice_fallback ;;
    esac
}

_install_vscode_apt() {
    local deb="$HOME/Downloads/vscode.deb" || return 1
    wget -O "$deb" "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" || return 1
    sudo apt-get install -y "$deb" || return 1
    rm -f "$deb"
}

_install_vscode_dnf() {
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc || return 1
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" \
        | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null || return 1
    sudo dnf check-upgrade || return 1
    sudo dnf install -y code || return 1
}

_install_vscode_pacman() {
    install_aur_pkg_bypass "visual-studio-code-bin" || return 1
}

_install_vscode_xbps() {
    install_pm_pkg_bypass "vscode" || return 1
}

_install_vscode_zypper() {
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" \
        | sudo tee /etc/zypp/repos.d/vscode.repo >/dev/null
    sudo zypper ref || return 1
    sudo zypper in -y code || return 1
}

_install_vscode_fallback() {
    if [ "$flatpak_installed" -eq 1 ]; then
        install_flatpak_pkg_bypass "com.visualstudio.code"

    elif [ "$snap_installed" -eq 1 ]; then
        sudo snap install code --classic
    else
        unsupported_package_manager
        return 1
    fi
}

install_vscode() {
    detect_system
    case "$primary_pm" in
        apt)    _install_vscode_apt ;;
        dnf)    _install_vscode_dnf ;;
        pacman) _install_vscode_pacman ;;
        xbps)   _install_vscode_xbps ;;
        zypper) _install_vscode_zypper ;;
        *)      _install_vscode_fallback ;;
    esac
}

_install_vscodium_apt() {
    sudo wget https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
        -O /usr/share/keyrings/vscodium-archive-keyring.asc || return 1

    echo 'deb [ arch=amd64 signed-by=/usr/share/keyrings/vscodium-archive-keyring.asc ] https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs vscodium main' \
        | sudo tee /etc/apt/sources.list.d/vscodium.list || return 1

    sudo apt-get refresh || return 1
    sudo apt-get install -y codium || return 1
}

_install_vscodium_dnf() {
    sudo tee -a /etc/yum.repos.d/vscodium.repo <<-'EOF' || return 1
[gitlab.com_paulcarroty_vscodium_repo]
name=gitlab.com_paulcarroty_vscodium_repo
baseurl=https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
metadata_expire=1h
EOF
    sudo dnf check-upgrade || return 1
    sudo dnf install -y codium || return 1
}

_install_vscodium_pacman() {
    install_aur_pkg_bypass "vscodium-bin" || return 1
}

_install_vscodium_zypper() {
    sudo tee -a /etc/zypp/repos.d/vscodium.repo <<-'EOF' || return 1
[gitlab.com_paulcarroty_vscodium_repo]
name=gitlab.com_paulcarroty_vscodium_repo
baseurl=https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
metadata_expire=1h
EOF
    sudo zypper ref || return 1
    sudo zypper in -y codium || return 1
}

_install_vscodium_fallback() {
    if [ "$flatpak_installed" -eq 1 ]; then
        install_flatpak_pkg_bypass "com.vscodium.codium"

    elif [ "$snap_installed" -eq 1 ]; then
        sudo snap install codium --classic
    else
        unsupported_package_manager
        return 1
    fi
}

install_vscodium() {
    detect_system
    case "$primary_pm" in
        apt)    _install_vscodium_apt ;;
        dnf)    _install_vscodium_dnf ;;
        pacman) _install_vscodium_pacman ;;
        zypper) _install_vscodium_zypper ;;
        *)      _install_vscodium_fallback ;;
    esac
}
