#!/bin/bash
prog=$(basename $0)

fn_help() {
    echo "    ____                            _____            __  _            __     "
    echo "   / __ \____  ____ ___  _____     / ___/___  ____  / /_(_)___  ___  / /____ "
    echo "  / /_/ / __ \/ __ \`/ / / / _ \    \__ \/ _ \/ __ \/ __/ / __ \/ _ \/ / ___/ "
    echo " / _, _/ /_/ / /_/ / /_/ /  __/   ___/ /  __/ / / / /_/ / / / /  __/ (__  )  "
    echo "/_/ |_|\____/\__, /\__,_/\___/   /____/\___/_/ /_/\__/_/_/ /_/\___/_/____/   "
    echo "            /____/                                                           "
    echo ''
    echo -e "\e[1m\e[92m Hacker toolkit provided by the RogueSentinels hacker group\e[0m"
    echo -e " Target engagement: \e[1mNeptune Shipping & Logistics S.A.\e[0m (neptune-shipping.be)"
    echo ''
    echo " Usage: $prog <subcommand> [options]"
    echo ' Commands:'
    echo '    workstation-setup   Setup Docker & utilities on the workstation (sudo)'
    echo '    emulation-setup     (ARM/Mac only, rarely needed) install amd64 emulation fallback'
    echo '    upgrade             Fetch latest scenario (versions + compose)'
    echo '    up                  Launch the attack environment'
    echo '    down                Stop the attack environment'
    echo ''
}

fn_upgrade() {
    echo "Fetch latest scenario versions"
    mkdir -p "$HOME/.roguesentinels"
    wget -q -O "$HOME/.roguesentinels/versions.json" https://raw.githubusercontent.com/RogueSentinels/hacker-toolkit/main/versions.json
    wget -q -O "$HOME/.roguesentinels/docker-compose.yaml" https://raw.githubusercontent.com/RogueSentinels/hacker-toolkit/main/docker-compose.yaml
}

# Exporte RS_<NOM>_VERSION pour chaque image de versions.json (ex: backup-host -> RS_BACKUP_HOST_VERSION)
fn_load_versions() {
    while IFS=$'\t' read -r k v; do
        var="RS_$(echo "$k" | tr 'a-z-' 'A-Z_')_VERSION"
        export "$var=$v"
    done < <(jq -r 'to_entries[] | "\(.key)\t\(.value)"' "$HOME/.roguesentinels/versions.json")
}

# Les images sont multi-arch : sur ARM (Mac Apple Silicon) Docker tire la variante arm64
# NATIVE, y compris le DNS -> aucune emulation necessaire. On informe seulement l'utilisateur.
fn_arch_notice() {
    arch=$(uname -m)
    if [ "$arch" = "aarch64" ] || [ "$arch" = "arm64" ]; then
        echo -e "\e[1m\e[92mArchitecture ARM detectee : images arm64 natives (DNS inclus), pas d'emulation.\e[0m"
        echo -e "   (En cas de souci avec une image, lancez une fois : sudo ./attack.sh emulation-setup)"
    fi
}

fn_emulation-setup() {
    echo "Installation du fallback d'emulation amd64 (tonistiigi/binfmt)..."
    sudo docker run --privileged --rm tonistiigi/binfmt --install amd64
    echo "Fait. Relancez './attack.sh up'."
}

fn_dns-setup() {
    echo -e "\n\e[1m\e[92mDisabling auto-DNS provided by DHCP\e[0m"
    sudo nmcli con mod "Wired connection 1" ipv4.ignore-auto-dns yes
    echo -e "\e[1m\e[92mChanging main DNS server to 192.168.30.50\e[0m"
    sudo nmcli con mod "Wired connection 1" ipv4.dns "192.168.30.50 1.1.1.1"
    echo -e "\e[1m\e[92mRestarting Kali network manager\e[0m"
    sudo systemctl restart NetworkManager
}

fn_dns-disable() {
    echo -e "\n\e[1m\e[92mEnabling auto-DNS provided by DHCP\e[0m"
    sudo nmcli con mod "Wired connection 1" ipv4.ignore-auto-dns no
    echo -e "\e[1m\e[92mChanging main DNS server to 1.1.1.1\e[0m"
    sudo nmcli con mod "Wired connection 1" ipv4.dns "1.1.1.1"
    echo -e "\e[1m\e[92mRestarting Kali network manager\e[0m"
    sudo systemctl restart NetworkManager
}

fn_up() {
    fn_upgrade
    fn_arch_notice
    fn_load_versions
    docker compose -f $HOME/.roguesentinels/docker-compose.yaml up -d "$@"
    if [[ "$*" != *"--skip-dns"* ]]; then fn_dns-setup; fi
    echo -e "\n\e[1m\e[92mEnvironnement pret. Verifiez le DNS :\e[0m dig neptune-shipping.be"
}

fn_down() {
    fn_load_versions
    docker compose -f $HOME/.roguesentinels/docker-compose.yaml down "$@"
    if [[ "$*" != *"--skip-dns"* ]]; then fn_dns-disable; fi
}

fn_workstation-setup() {
    if [ "$EUID" -ne 0 ]; then echo "Use 'sudo' to launch this command (root access required)"; exit 1; fi
    echo 0 | sudo tee /proc/sys/kernel/randomize_va_space
    echo "Installing Docker CE & utilities"
    sudo apt remove docker docker-engine docker.io containerd runc 2> /dev/null
    sudo apt update
    sudo apt install -y jq ca-certificates curl gnupg lsb-release
    sudo mkdir -p /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    sudo tee /etc/apt/sources.list.d/docker.sources <<DOCKEREOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: buster
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
DOCKEREOF
    sudo apt-get update
    sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo usermod -aG docker $USER
    echo 'Disconnect from current Kali session and launch new terminal. Test with "docker compose version"'
}

subcommand=$1
case $subcommand in
    "" | "-h" | "--help") fn_help ;;
    *) shift; fn_${subcommand} $@
       if [ $? = 127 ]; then
          echo "Error: '$subcommand' is not a known subcommand." >&2
          echo "       Run '$prog --help' for a list of known subcommands." >&2
          exit 1
       fi ;;
esac
