<p align="center">
    <img src="./docs/header.png" />
</p>

## Introduction

```sh
# Install the toolkit on a Kali Linux 64-bit
wget https://raw.githubusercontent.com/RogueSentinels/hacker-toolkit/main/attack.sh && chmod +x attack.sh

# Get your workstation ready
sudo ./attack.sh workstation-setup

# Start the attack !
./attack.sh up
```

This reposisitory contains useful brute-force wordlists in the `wordlists` directory.

## The DNS is not working

To check if the DNS server is working, perform a basic DNS request to the local server using the command below.

```sh
# Try to perform a local DNS request with the command below. If the answer
# does NOT contain "contact@rs.io", the Docker container is probably not 
# started yet. Start with "./attack.sh up" or inspect with "docker ps".
dig @192.168.30.50 rs.io

# Try to perform a local DNS request without specifying the Docker container.
# If the answer does NOT contain "contact@rs.io", you workstation is not
# configured properly: register the DNS server "192.168.30.50" and restart 
# your network interface.
dig rs.io
```
