# How to setup a Minecraft Server using WireGuard
<h2>Disclaimer <img alt=":meow_bounce:" src="https://emojis.slackmojis.com/emojis/images/1643515239/12570/meow_bounce.gif?1643515239" width="40"> </h2>
> This guide is intended to provide information and guidance on how to setup a private Minecraft server using WireGuard. Every effort has been made to ensure that the information presented in this guide is as accurate as possible. Despite this, it is possible that some information in this guide may be inaccurate. So do it at your own risk. I encourage people reading this guide to consult relevant online sources to enhance the guides accuracy and maybe learn more along the way.
## Introduction
In this guide, I will cover how to create a private Minecraft server using [WireGuard Easy](https://github.com/wg-easy/wg-easy). This guide is meant for private Minecraft servers, using WireGuard to host a public Minecraft server is not recommended as there are better methods to achieve that. If you are looking to host a public Minecraft server, consider hosting with a [VPS](https://en.wikipedia.org/wiki/Virtual_private_server). This guide will cover everything from WireGuard basics, configuring the operating system, and deploying the Minecraft server.
### Purpose & Motivation
I utilized WireGuard for a project when I was developing [StorageSolution](https://github.com/ShiroTohu/StorageSolution). **StorageSolution** was a full-stack application developed for an assignment. It allowed the contents of chests to be accessed by players in my private Minecraft server. I did not want to expose this application to the internet, especially because the API was implemented very poorly. So I utilized WireGuard to allow only a select few to use the API.

WireGuard has now become my preferred way to host Minecraft servers with my friends as it grants an extra layer of security and piece of mind.
### Target Audience
I wrote this guide with beginners in mind as I suspect that most people reading this guide might be new to networking. Though, unlike the previous iteration of this guide, I won't be going through what WireGuard is and why it is helpful in this scenario. Keeping the guide concise is important for future referencing and maintenance.

I encourage those who are not familiar with networking, docker and Linux to not follow this guide blindly and understand what the concepts described.
### Hardware Requirements
There are many different ways you could set your VPN up and topologies to choose from that requires different requirements. But they usually come down to these components.
 - Computer to act as the WireGuard [gateway](https://en.wikipedia.org/wiki/Default_gateway) (Usually a Linux based system)
 - Computer for the Minecraft server
 - Micro SD Card / USB Drive (to install Linux)
You could combine the gateway and Minecraft server if needed as the performance impacts of the gateway are negligible.
## Setting Up the Gateway
For our gateway we will be using [wg-easy](https://github.com/wg-easy/wg-easy) on a Debian based distro. This will provide us a nice web UI to manage our connections remotely and make it more easier to download configuration files. wg-easy also configures WireGuard out of the box as well.

Some things to consider if you are planning to do this on either Windows or Mac:
- If you are on Windows consider using [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) which allows you to use Linux applications directly on windows. This will allow you to follow the guide more closely.
- If you are on Windows or Mac you could also virtualize Linux using [VirtualBox](https://www.virtualbox.org/). This allows you to run a "guest machine" on top of your existing "host machine". You can follow this [guide](https://ubuntu.com/tutorials/how-to-run-ubuntu-desktop-on-a-virtual-machine-using-virtualbox#1-overview) to get started.
	- Make sure to use a bridged adapter to make the computer accessible on your LAN network if you want to SSH.
	- Make sure that you have virtualization enabled on your computer.
	- Make sure that you are using the server image instead of the desktop image to save some performance.
### Installing Linux
For running the gateway I recommend [Ubuntu Server](https://ubuntu.com/download/server) due to it's wide enterprise use. If you are running on a Raspberry Pi I recommend [Raspberry Pi OS](https://www.raspberrypi.com/software/) and flashing the iso file using the [Raspberry Pi Imager](https://www.raspberrypi.com/software/). Though, any Debian based distro should suffice.

Enabling SSH is a pretty good idea, it allows you to remotely access your server using your username and password.
```
sudo apt update && sudo apt upgrade
sudo apt install openssh-server net-tools git
sudo ufw allow ssh
```
You can find the IP address of the server using the following command. The IP address can be seen after `inet`.
```
ifconfig
```
you can then login using the following format below on any other PC. You will be prompted to type in your password after you execute this command.
```
ssh <username>@<server_ip_address>
```
### Install Docker
The first line installs docker using modified [docker-install](https://github.com/docker/docker-install)  install command. It then adds the current user to the docker group. It gets the current user using the `whoami` shell command.
```
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker $(whoami)
exit
```
### Install wg-easy
First we need to clone the repository, we only really want the `docker-compose.yml` file as we will be editing it for the install.
```
git clone https://github.com/wg-easy/wg-easy.git
cd wg-easy
```
We first need to generate a password hash. We can use wg-easy hashing tool they created to make this process easier. I have modified the command from the [wg-password wiki page](https://github.com/wg-easy/wg-easy/blob/master/How_to_generate_an_bcrypt_hash.md) to replace $ symbols with \$\$ and start with a dash. 
```
docker run --rm -it ghcr.io/wg-easy/wg-easy wgpw 'YOUR_PASSWORD' | sed -e 's/\$/\$\$/g' -e 's/^/- /'
```
When WireGuard is activated those who connect through your VPN can access your LAN network.
```
- WG_POST_UP=iptables -I FORWARD -i wg0 -d 192.168.X.0/24 -j REJECT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
- WG_POST_DOWN=iptables -D FORWARD -i wg0 -d 192.168.X.0/24 -j REJECT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```
deploy docker container.
```
docker compose up --detach
```
### Port Forwarding
Port forwarding is different for everyone as different routers have different gateways. You can find the default gateway of your network using `ipconfig` on windows, `route -n get default` on mac and `ip route` on Linux.

You use this IP address to log into your router, usually it is `192.168.0.1`, you need to find the port forwarding section and add these rules.
- Original Port 51820
- Forward to Port 51820
- Protocol TCP/UDP
- Forward to Address is the LAN address of the WireGuard Server.
- Description can be anything you want
Make sure to save these rules.

> [!WARNING]
> Some Internet providers utilize **Carrier-grade NAT or CG-NAT** This basically hides your public IP address from the internet and it is impossible to receive information when the packets are being blocked by the CG-NAT firewall. In this case you need to call your provider and change to a Dynamic IP Address. 
## Installing PaperMC
PaperMC is my go to server hosting software for Minecraft, though the steps should be similar for any other server hosting software whether that be modded, vanilla, spigot etc.
### Creating User For the Server
### Installing Java
