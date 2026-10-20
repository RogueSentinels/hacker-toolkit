<p align="center">
    <img src="./docs/header.png" />
</p>

## Introduction

```sh
# Install the toolkit on a Kali Linux (amd64 OU arm64 / Mac Apple Silicon)
wget https://raw.githubusercontent.com/RogueSentinels/hacker-toolkit/main/attack.sh && chmod +x attack.sh

# Get your workstation ready
sudo ./attack.sh workstation-setup

# Start the attack !
./attack.sh up
```

This repository contains useful brute-force wordlists in the `wordlists` directory.

## Main target

Your main target is the local domain **`neptune-shipping.be`** (Neptune Shipping & Logistics S.A.)
- IT IS NOT the real Internet — everything resolves on the LOCAL network `192.168.30.0/24`
- ALWAYS GO THROUGH THE LOCAL DNS RESOLVER `192.168.30.50`

## Apple Silicon / ARM (macOS)

Rien de special a faire : les images sont **multi-arch**. Sur un Kali ARM64, Docker telecharge
automatiquement les variantes **arm64 natives** — y compris le serveur **DNS**. La reconnaissance
par nom de domaine fonctionne donc desormais aussi sur Mac. (Si une image posait probleme, lancez
une seule fois `sudo ./attack.sh emulation-setup`.)

## The DNS is not working

```sh
# Doit renvoyer un enregistrement contenant "neptune-shipping.be" (TXT: contact@neptune-shipping.be).
dig @192.168.30.50 neptune-shipping.be

# Sans preciser le serveur : si pas de reponse, votre workstation n'est pas configuree :
# enregistrez le DNS "192.168.30.50" et relancez l'interface reseau (./attack.sh up le fait).
dig neptune-shipping.be
```
