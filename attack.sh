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
    echo ''

    echo " Usage: $prog <subcommand> [options]"
    echo ' Commands:'
    echo ''
    echo '    workstation-setup   Setup Docker & utilities on the workstation'
    echo '    upgrade             Upgrade attack environment to latest versions'
    echo '    up                  Launch the RogueSentinels attack environment'
    echo '    down                Stop the RogueSentinels attack environment'
    echo ''
    echo ' For help with each subcommand run:'
    echo " $prog <subcommand> -h|--help"
    echo ''
}

fn_upgrade() {

    echo "Fetch latest versions"
    mkdir -p "$HOME/.roguesentinels"
    wget -q -O "$HOME/.roguesentinels/versions.json" https://raw.githubusercontent.com/RogueSentinels/hacker-toolkit/main/versions.json
    wget -q -O "$HOME/.roguesentinels/docker-compose.yaml" https://raw.githubusercontent.com/RogueSentinels/hacker-toolkit/main/docker-compose.yaml
}

fn_dns-setup() {

    echo ""
    echo -e "\e[1m\e[92mDisabling auto-DNS provided by DHCP\e[0m"
    sudo nmcli con mod "Wired connection 1" ipv4.ignore-auto-dns yes

    echo ""
    echo -e "\e[1m\e[92mChanging main DNS server to 192.168.30.50\e[0m"
    sudo nmcli con mod "Wired connection 1" ipv4.dns "192.168.30.50 1.1.1.1"

    echo ""
    echo -e "\e[1m\e[92mRestarting Kali network manager\e[0m"
    sudo systemctl restart NetworkManager

    echo ""

}

fn_dns-disable() {

    echo ""
    echo -e "\e[1m\e[92mEnabling auto-DNS provided by DHCP\e[0m"
    sudo nmcli con mod "Wired connection 1" ipv4.ignore-auto-dns no

    echo ""
    echo -e "\e[1m\e[92mChanging main DNS server to 1.1.1.1\e[0m"
    sudo nmcli con mod "Wired connection 1" ipv4.dns "1.1.1.1"

    echo ""
    echo -e "\e[1m\e[92mRestarting Kali network manager\e[0m"
    sudo systemctl restart NetworkManager

    echo ""

}

fn_up() {

    fn_upgrade

    export RS_DNS_VERSION=$(cat $HOME/.roguesentinels/versions.json | jq -r ".dns" |  tr -d '\n')
    export RS_ALPHA_VERSION=$(cat $HOME/.roguesentinels/versions.json | jq -r ".alpha" |  tr -d '\n')
    export RS_BETA_VERSION=$(cat $HOME/.roguesentinels/versions.json | jq -r ".beta" |  tr -d '\n')
    export RS_GAMMA_VERSION=$(cat $HOME/.roguesentinels/versions.json | jq -r ".gamma" |  tr -d '\n')
    export RS_DELTA_VERSION=$(cat $HOME/.roguesentinels/versions.json | jq -r ".delta" |  tr -d '\n')
    export RS_EPSILON_VERSION=$(cat $HOME/.roguesentinels/versions.json | jq -r ".epsilon" |  tr -d '\n')
    export RS_ZETA_VERSION=$(cat $HOME/.roguesentinels/versions.json | jq -r ".zeta" |  tr -d '\n')

    docker compose -f $HOME/.roguesentinels/docker-compose.yaml up -d

    fn_dns-setup
}

fn_down() {

    export RS_DNS_VERSION=$(cat $HOME/.roguesentinels/versions.json | jq -r ".dns" |  tr -d '\n')
    export RS_ALPHA_VERSION=$(cat $HOME/.roguesentinels/versions.json | jq -r ".alpha" |  tr -d '\n')
    export RS_BETA_VERSION=$(cat $HOME/.roguesentinels/versions.json | jq -r ".beta" |  tr -d '\n')
    export RS_GAMMA_VERSION=$(cat $HOME/.roguesentinels/versions.json | jq -r ".gamma" |  tr -d '\n')
    export RS_DELTA_VERSION=$(cat $HOME/.roguesentinels/versions.json | jq -r ".delta" |  tr -d '\n')
    export RS_EPSILON_VERSION=$(cat $HOME/.roguesentinels/versions.json | jq -r ".epsilon" |  tr -d '\n')
    export RS_ZETA_VERSION=$(cat $HOME/.roguesentinels/versions.json | jq -r ".zeta" |  tr -d '\n')

    docker compose -f $HOME/.roguesentinels/docker-compose.yaml down

    fn_dns-disable
}

fn_workstation-setup() {

    if [ "$EUID" -ne 0 ]
        then echo "Use 'sudo' to launch this command (root access required)"
        exit 1
    fi

    echo 0 | sudo tee /proc/sys/kernel/randomize_va_space

    echo "Installing Docker CE & utilities"
    echo -e "\e[1m\e[92m(1/5) Prepare workstation\e[0m"
    sudo apt remove docker docker-engine docker.io containerd runc 2> /dev/null
    sudo apt update
    sudo apt install -y jq ca-certificates curl gnupg lsb-release

    echo -e "\e[1m\e[92m(2/5) Install Docker keyring\e[0m"
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    echo -e "\e[1m\e[92m(3/5) Add APT repository\e[0m"
    printf "%s\n" "deb [arch=amd64] https://download.docker.com/linux/debian buster stable" | sudo tee /etc/apt/sources.list.d/docker-ce.list
    sudo apt update

    echo -e "\e[1m\e[92m(4/5) Install Docker CE\e[0m"
    sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    echo -e "\e[1m\e[92m(5/5) Post-installation steps\e[0m"
    sudo usermod -aG docker $USER
    echo 'Disconnect from current Kali session and launch new terminal'
    echo 'Test with "docker compose version"'
}
  
subcommand=$1
case $subcommand in
    "" | "-h" | "--help")
        fn_help
        ;;
    *)
        shift
        fn_${subcommand} $@
        if [ $? = 127 ]; then
            echo "Error: '$subcommand' is not a known subcommand." >&2
            echo "       Run '$prog --help' for a list of known subcommands." >&2
            exit 1
        fi
        ;;
esac
