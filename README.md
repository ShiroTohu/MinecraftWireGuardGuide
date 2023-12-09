# How To Setup A Private Minecraft Server Using PiVPN and WireGuard 
<h2>Disclaimer <img alt=":meow_bounce:" src="https://emojis.slackmojis.com/emojis/images/1643515239/12570/meow_bounce.gif?1643515239" width="40"> </h2>

> This guide is intended to provide information and guidance on how to setup a private Minecraft server using WireGuard. Every effort has been made to ensure that the information presented in this guide is as accurate as possible. Despite this, it is possible that some information in this guide may be inaccurate. I encourage people reading this guide to consult relevant online sources to enhance the guides accuracy and maybe learn more along the way. I have linked the sources used in this guide in the [footnotes](#footnotes) section and suggest going there for further reading. <3


## Table of Contents
 1. [Introduction](#introduction)
    1. [Purpose & Motivation](#purpose--motivation)
    2. [Target Audience](#target-audience)
    3. [Overview of Steps](#overview-of-steps)
    4. [Any Prerequisites or Requirements?](#any-prerequisites-or-requirements)
    5. [Encouragement & Direction](#encouragement--direction)
 2. [What is WireGuard?](#what-is-wireguard)<br>
    1. [Why WireGuard to Host a Minecraft Server?](#why-wireguard-to-host-a-minecraft-server)
    2. [Is WireGuard Safe?](#is-wireguard-safe)
    3. [How Does It Work?](#how-does-it-work)
    4. [Any Alternatives?](#any-alternatives)
    5. [Further Reading](#further-reading)
 3. [Choosing Server Topology]()
    1. [Separated Servers]()
    2. [Combined Servers]()
    3. [Personal PC Host]()
    4. ["The Boy's Got Me" Topology]()
 4. [Setting Up The Operating System]()
 5. [SSHing into your server]()
 6. [Setting Up PiVPN]()
    1. [WireGuard On Debian Based Operating Systems Using PiVPN]()
 7. [Creating Key Pairs]()
 8. [Distributing Key Pairs]()
 9. [Creating The Minecraft Server]()
    1. [Vanilla Server]()
    2. [Spigot Server]()
    3. [PaperMC Server]()
    4. [Modded Server]()
    5. [Modded Server Using CurseForge]()
 1. [DNS Configuration]()
    1. [PiHole]()
    2. [CloudFlare]()
 2. [Changes]()
 3. [Contributing]()
 4. [Footnotes]()


## Introduction
In this guide, I will cover how to create a private Minecraft server using PiVPN & WireGuard. This guide is meant for private Minecraft servers, using WireGuard to host a public Minecraft server is not recommended as there are better methods of doing that. If you are looking to host a public Minecraft server, consider hosting with a VPS or Paid Provider. This guide will cover everything from WireGuard basics, configuring the the operating system, deploying the minecraft server and more.

I have also uploaded a video on my YouTube channel in case you want to follow along in video format. Keep in mind that throughout the video you will have to refer back to specific parts of the guide so that you will have the most up to date information. The video also uses the recommended items and topology. For cases not covered in the video don't worry as they shouldn't differ too much from the video. 

<!-- This is here, so that I can get a general understanding of what a youtube video looks like in the document -->
[![Temporary Youtube Link](https://img.youtube.com/vi/xXvBp3Tgwqs/0.jpg)](https://www.youtube.com/watch?v=xXvBp3Tgwqs)


### Purpose & Motivation ~
I utilized PiVPN and WireGuard when I was developing [StorageSolution](https://github.com/ShiroTohu/StorageSolution). **StorageSolution** is a full-stack application I developed that allowed the computers from [CC: Tweaked](https://tweaked.cc/) to display all the items in my storage system in a nice and presentable manner using Python [Textualize](https://www.textualize.io/). I created a backend API to distribute the contents of my storage system to the frontend where the end-user could then see the items in table format. Examples online showed backend solutions using [ngrok](https://ngrok.com/) that exposed the backend to the internet. This isn't something that I really wanted since anyone could establish a websocket connection with the server, therefore to limit the server's exposure I setup a WireGuard VPN in a configuration where both the Minecraft and backend server was located within the VPN (Virtual Private Network).

Ever since then, WireGuard has been my preferred way to host my private Minecraft servers with peers. I also wanted to document the process since there are limited resources out there to help since I've been setting up these servers for a while.


### Target Audience ~
I wrote this guide with beginners in mind as I suspect that most people reading this guide might be new to networking or just want a way to play with friends. This guide is the equivalent on the `-vv` argument flag as this guide contains much information I could possibly cram.


### Overview of Steps
There is a lot of filler mixed into this guide, therefore make sure to lookout for headers that have a tailing `~` symbol.
- What is WireGuard?
  - Here I explain what WireGuard is, how it works, and whether it is suitable for the task of hosting a Minecraft server. I will then try and address any concerns you might have alongside listing alternative methods you can use instead. 
- Choosing Server Topology
- Setting Up The Operating System
- SSHing into your server
- Setting Up WireGuard
- Creating Key Pairs
- Distributing Key Pairs
- Creating the Minecraft Server
- DNS Configuration
- Changes


### Any Prerequisites or Requirements?
Below I have listed the prerequisite items needed in order to complete this guide. Though, the items stated is just a recommendation. There are many different ways you can configure the WireGuard server to suit your needs. Feel free to look at the [Choosing Server Topology](#choosing-server-topology) section of the guide where I go more in depth in different ways you can configure the WireGuard Server.

- Recommended
  - Micro SD Card / USB Drive
  - Internet Connection
  - Debian Based Computer (PiVPN)
  - Computer (Minecraft Server)
  - Computer (To play on)
- Minimum
  - Internet Connection
  - Computer (PiVPN, Minecraft Server, To play on)


###  Encouragement & Direction ~
I know some of you might want to get straight in and skip sections in order to get this setup straight away, that's great! but, I do recommend reading the [Why WireGuard?](#why-wireguard) section if you are thinking of doing that as you might find that WireGuard might not be for you. If you are determined to get started good luck on your journey! :)


## What is WireGuard?
Before explaining what WireGuard is I think it is important to understand what a VPN generally is and the basic operations of it.

> A virtual private network (VPN) is a mechanism for creating a secure connection between a computing device and a computer network, or between two networks, using an insecure communication medium such as the public Internet.[^1]

[^1]: https://en.wikipedia.org/wiki/Virtual_private_network

A WAN (Wide Area Network) is a network that extends over multiple geographical regions[^2]. An institution could deploy a WAN completely separate from the public internet, so that data sent from the hosts and servers are sent in a secure and confidential manner, this would be referred to as a **private network**[^3]. Private Networks can be quite costly in where the institution would have to purchase, install and maintain their own physical network infrastructure[^3]. Therefore, nowadays, institutions deploy VPN's to solve the same problem. VPN use the existing public internet rather than an separate independent network. To provide the confidentiality that the separate network provided, the traffic is encrypted before it is sent over the public internet[^3] .

[^2]: https://en.wikipedia.org/wiki/Wide_area_network
[^3]: Kurose, J. F., & Ross, K. W., (2017) Computer Networking: A Top-Down Approach (pp. 666). Pearson Education Limited.
[^4]: https://www.fortinet.com/resources/cyberglossary/cia-triad

WireGuard is a relatively new open source VPN solution that uses state-of-the-art cryptography. It aims to be faster and more simpler to learn than other alternatives. On the WireGuard website it states the following 5 principles[^4]: 
 - Simple & Easy-to-use
 - Cryptographically Sound
 - Minimal Attack Surface
 - High Performance
 - Well Defined & Thoroughly Considered

[^4]: https://www.wireguard.com/

It was specifically created for the Linux Kernel by Jason A. Donenfeld in 2015 though has spread to other platforms as well such as IOS, Android, Mac and Windows.

![WireGuard Performance](https://camo.githubusercontent.com/df839dac23d4005ea3ec3a65bae98fb87ec86960323e2138039361b8e80ad2e1/68747470733a2f2f7777772e636b6e2e696f2f696d616765732f7769726567756172645f636f6d7061726973696f6e732e706e67)
(See https://www.ckn.io/blog/2017/11/14/wireguard-vpn-typical-setup/ this image was also taken from the [Unofficial WireGuard Documentation](https://github.com/pirate/wireguard-docs))

WireGuard is quite performant compared to other VPN solutions as seen above. The results are similar to the [findings](https://www.wireguard.com/performance/) on the WireGuard official website. Though both of these benchmarks seem to be outdated. Though in a recent finding (2023) found [here](https://restoreprivacy.com/vpn/wireguard-vs-openvpn/) WireGuard still outperforms OpenVPN. This speed is what we want when running a minecraft server.

[^5]: https://www.wireguard.com/performance/


### Is WireGuard Safe?
According to [All About Cookies](https://allaboutcookies.org/) WireGuard is considered to be "one of the safest, most secure VPN protocol options available today."[^6] It also has the added benefit that it is used by popular VPN software such as [NordVPN](https://nordvpn.com/nord-site/), [SurfShark](https://surfshark.com/), [CyberGhost](https://www.cyberghostvpn.com/en_US/), and [MullVAD VPN](https://mullvad.net/en).

WireGuard does have a security flaw out of the box though. When using other services such as OpenVPN you are assigned a different IP address each time you connect, though with WireGuard your IP address remains static and unchanging. "This is faster, but it means the VPN server must keep logs of your real IP address and connection timestamps."[^7] It should be mentioned though that the VPN providers using WireGuard circumvented this issue by modifying WireGuard with their own systems to get around this flaw[^7]. In this guide we won't be covering that since that is likely way out of my expertise.

[^6]: https://allaboutcookies.org/wireguard-vpn-protocol
[^7]: https://www.tomsguide.com/how-to/is-the-new-wireguard-protocol-secure


### How Does WireGuard Work?

TODO...


### What is IPTables?

TODO...


### Should WireGuard be used to Host a Minecraft Server?
WireGuard has many advantages in the VPN space. Though should you create a WireGuard VPN for the sole purpose of hosting a Minecraft server?

> The only scenario in which a VPN would help you is if you ran a VPN gateway in your network and have the Minecraft server accessible only to those with access to your VPN. The problem is, that this is way more difficult to set up, and even more difficult to set up in a secure manner. Just forwarding a port to your Minecraft server is way less likely to get you into any troubles.
>
> https://www.ckn.io/blog/2017/11/14/wireguard-vpn-typical-setup/

This is exactly what we are doing to do in this guide. Port forwarding to your Minecraft server to the internet isn't that insecure. As long as you have a whitelist you should be fine from unexpected visitors. If you also want to go the extra step you can also disable [SLP](https://wiki.vg/Server_List_Ping) which is what was used to detect active minecraft servers in LiveOverFlow's [video](https://youtu.be/VIy_YbfAKqo?list=PLhixgUqwRTjwvBI-hmbZ2rpkAl4lutnJG&t=665) where he scanned the internet for open Minecraft servers.

There are very rare cases where a VPN would is valid option to use as seen in my [StorageSolution example](#purpose--motivation). But I think whether you want to use WireGuard to host a Minecraft server would come down to personal preference, whether you want to learn some networking skills or don't trust the Minecraft servers.


### Any Alternatives? ~
This section will list some alternatives I have found. I will first describe the functions of the alternative before delving into the similarities and differences between the alternative and our chosen method.

|Alternatives|Explanation|
|---|---|
[Port Forwarding](https://www.hostinger.com/tutorials/how-to-port-forward-a-minecraft-server)|Port Forwarding is an application of the NAT (Network Address Translation) that reroutes communications from one pair of IP and port number combination to another through the network gateway [^8]. 
[OpenVPN](https://openvpn.net/)|TODO...
[IPSec](https://en.wikipedia.org/wiki/IPsec)|TODO...
[Hamachi](https://vpn.net/)|TODO...
[TwinGate](https://www.twingate.com/)|TODO...
[Radmin VPN](https://www.radmin-vpn.com/)|TODO...
[ZeroTier One](https://www.zerotier.com/)|TODO...
[Ngrok](https://ngrok.com/)|TODO...
[ESSENTIALS Mod](https://www.curseforge.com/minecraft/mc-mods/essential-mod)|Essentials is a quality of life mod that allows you to host singleplayer worlds to peers. It also adds some other things that brighten the social aspects of Minecraft like cosmetics and a wardrobe feature. The Mod is available for both [Forge](https://forums.minecraftforge.net/) and [Fabric](https://fabricmc.net/).<br><br>As for the difference between the Essentials Mod and WireGuard it is much more simpler to setup and takes out a lot of the hassle of creating a connection. As for how essentials achieves this is unknown to me.

[^8]: https://en.wikipedia.org/wiki/Port_forwarding


## Choosing Server Topology
Each server topology requires different sets of prerequisites. You can choose any server topology depending on what you have available to you. For simplicity, this guide will be using the recommended configuration. This isn't a big issue, but if something in the guide deviates from your desired topology I will notify you. Below is a list of the server topologies supported by this guide:

 - [Recommended Configuration]()
 - [Combined Gateway and Server Configuration]()
 - [Computer Host Configuration]()
 - [All In One Configuration]()
 - [Separated Network Configuration]()


### Recommended Configuration
This is the recommended configuration where we have the load distributed against three different computers. You are less likely to run into any performance issues with this setup.
<p align="center">
  <img src="./img/topologies/Diagram1.JPG" width="650px"/>
</p>

**Prerequisites**
 - Internet Connection
 - Debian Based Computer (PiVPN)
 - Computer (Minecraft Server)
 - Computer (To play on)


### Combined Gateway and Server Configuration
In this configuration the WireGuard Gateway and Minecraft server is combined. If the two servers are running on a Raspberry Pi I would advise going with a Minecraft server option that is lightweight like PaperMC or Forge with performance mods. WireGuard isn't very resource intensive from when I benchmarked it, so majority of the load will most likely be the Minecraft server.  
<p align="center">
  <img src="./img/topologies/Diagram2.JPG" width="650px" />
</p>

**Prerequisites**
 - Internet Connection
 - Debian Based Computer (PiVPN & Minecraft Server)
 - Computer (To play on)


### Computer Host Configuration
Assuming you shut off your computer at night. This is a good alternative if you are not planning to have the Minecraft server running 24/7. If you have a beefy computer that can handle running the game and server this isn't a bad option.

Another cool note with this setup, you don't actually have to setup the server. Instead you can just host through LAN instead and it should work exactly the same but with less steps!
<p align="center">
  <img src="./img/topologies/Diagram3.JPG" width="650px" />
</p>

**Prerequisites**
 - Internet Connection
 - Debian Based Computer (PiVPN)
 - Computer (To play on & Minecraft Server)


### All In One Configuration
<p align="center">
  <img src="./img/topologies/Diagram4.JPG" width="650px" />
</p>

**Prerequisites**
 - Internet Connection
 - Computer (PiVPN, Minecraft server and Personal Computer)

Note: The computer can be any operating system, though if it isn't debian based you will not be able to take the easy route of using PiVPN and it's features and will instead have to install WireGuard manually.


### Separated Network Configuration
This topology is more food for thought than anything, if you cannot host the Minecraft server on your local network then you are more than welcome to have that server located elsewhere.

<p align="center">
  <img src="./img/topologies/Diagram5.JPG" width="650px" />
</p>

 - Internet Connection
 - Debian Based Computer (PiVPN)
 - Computer (Minecraft Server)
 - Computer (To play on)


## Setting Up The Operating System


### Setting Up a Raspberry Pi
You want to download and install the [Raspberry Pi Imager](https://www.raspberrypi.com/software/) for your desired operating system. The imager is available for windows, mac, and linux. You'll also want a MicroSD readily available to use so that you can flash it onto there.

After you have installed the Raspberry Pi Imager launch the software and insert the MicroSD card into your computer.

In the imager, click on "Choose OS". Choose `Raspberry Pi OS Lite`. We want to choose the lite version as the desktop environment is heavy and can drain resources that we want allocated to the Minecraft/WireGuard Gateway. Depending on what Raspberry Pi you have, you'll chose either between the 32 or 64 bit variant. Since the 64 bit variant supports the Raspberry Pi 4, I will choose that.

From there we will be choosing the storage device we want to flash to. Be careful which one you choose as it will override all of the contents located on that drive.

We can customize the image by clicking the cog icon on the bottom left. Set the hostname to anything that you want, personally named mine `KambrookRiceExpress5CupRiceCooker` as it is a sneaky name that fits into all my other devices such as `BagOfDoritos` and `SecretLabsGamingChair`. A very important configuration step as well is configuring SSH. Password authentication will do just fine for our purposes and set a strong username and password. MAKE THE PASSWORD AND USERNAME UNIQUE AND STRONG. I cannot stress enough that SSH can be used for remote attacks so make it strong and unique. 

Configure WirelessLAN to point to your router, this will make it so that you are able to connect ot the internet when you boot up your Pi. I would only really recommend you do this if you don't have an ethernet cable as you can set it through SSH using `sudo raspi-config`.

Configure locale settings if you have too and click then click save.

Double check that you have selected the right drive write to the drive. Wait for it to finish and then eject it from your computer.

If you get an error message like below, **DO NOT** format it. If you have accidentally reformated the drive, just redo the steps mentioned above and you should be just fine.

![Alt text](img/operating-system/image-1.png)

for the guide this is the information that we have allocated to the Raspberry Pi


### Setting Up a Ubuntu Server

TODO...


## SSHing into your server
You will first need to find the local IP address of the device that you want to SSH into. I found mine by logging into my router/default gateway at `192.168.0.1` and finding my Raspberry Pi's IP address there. To SSH into your Raspberry PI fill in the following and paste in into your terminal where `xxx.xxx.xxx.xxx` is the IP address of your Pi and `username` is the username you assigned to your Raspberry Pi, this isn't to be confused with the host name.

```
ssh username@xxx.xxx.xxx.xxx
```

It will state that the authenticity of the host cannot be established and whether you are sure you want to proceed. type `yes`

It will then prompt you for a password. Don't get confused when it doesn't seem to be typing anything, it's just a precautionary it takes to make sure nobody is peaking. Just type it in as you usually do and then press enter.

TADA! you are now remotely accessing your Raspberry/Debian server.


## Setting Up WireGuard


### WireGuard On Debian Based Operating Systems Using PiVPN
SSH into the intended computer you want to host the gateway on. The install instructions might change in future so make sure to check the [PiVPN](https://pivpn.io/) for download instructions. But as of now, this is the command to install PiVPN:

```
curl -L https://install.pivpn.io | bash
```

from there you will be presented with a setup wizard. Read through the instructions as is and click **ok**, if there is any yes or no stuff it will be listed here.

![Alt text](img/pi-vpn/Capture4.JPG)

This is a result of me using VirtualBox to virtualize my Raspberry Pi during testing. If you get this message select **yes**.

![Alt text](img/pi-vpn/image.png)

We will answer **no** for the sake of keeping this guide more simple. Though if you know how to reserve a IP address feel free to select yes.

![Alt text](img/pi-vpn/image-1.png)
click yes

![Alt text](img/pi-vpn/image-2.png)
for me there is only one user. You could also create a user specifically for the purpose of holding your configurations, which is a good practice but isn't necessary.

[UPDATE THE GUIDE TO INCLUDE SEPARATE USERS.]

![Alt text](img/pi-vpn/image-3.png)
We are going with WireGuard!

![Alt text](img/pi-vpn/image-4.png)
here we are assigning a port number to the server. You can actually put really any number here from 0 to 65,535 but keep in mind some IP addresses are reserved so be careful. I like going with the default port number `51820`.

![Alt text](img/pi-vpn/image-5.png)
Here we are choosing our DNS provider. I like going with Cloudflare, but you can choose any one of these and you'll be fine. Apart from `PiVPN-is-local-DNS` and `custom`, you might run issues.

[Image Missing]
**Public IP or DNS**: Most of you will pick public IP address.

![Alt text](img/pi-vpn/image-6.png)
Yes

![Alt text](img/pi-vpn/image-7.png)
Reboot and you have successfully installed PiVPN!


## Creating Key Pairs
now we want to add a peer to our VPN. we view a list of commands using `pivpn -h`
![Alt text](./img/distributing-key-pairs/image.png)

We type in `pivpn -a` and a setup wizard will walk us through the instructions. We just have to input the name of our peer. To keep track of configuration files are connections, I usually assign the file with their Minecraft username. So if their username is `FartSmella` I would assign the .conf file with that appropriate name as seen below.

![Alt text](./img/distributing-key-pairs/image-1.png)

Now, a new folder has been created in your home directory. type `cd configs` and you can see that `FartSmella.conf` has been created.

![Alt text](./img/distributing-key-pairs/image-2.png)

you would distribute this file to others if they want to connect to your VPN. Though the default configuration of the file is kinda bad unfortunately and Users can alter the configuration of the file in order to get more access to resources. In order to prevent such a thing from occurring, we have to implement a firewall using IPTables.


### Contributing ~
please see [CONTRIBUTING.md](CONTRIBUTING.md).


### Footnotes ~
<!-- The footnotes will be automatically placed here. -->