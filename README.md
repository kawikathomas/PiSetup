# Raspberry Pi Setup

This is a collection of scripts I use to set up a Raspberry Pi. I primarily use them to run Ruby on Rails applications, so the current collection of scripts is focused on that. However, I have tried to avoid boxing myself into that, and would like to keep the install scripts as generic as possible.

## Preparation

This section covers the basics of getting your Pi up and running. It's mostly in place for my own documentation.

If you already have a working Pi and just want to use the Setup Scripts, jump to the [Installation](#installation) section below.

### Image your SD Card

#### Obtain the latest version of Raspbian

Visit the [Raspbian Download Page](https://www.raspberrypi.org/downloads/raspbian/) and download the latest version. I recommend **Stretch Lite** and using the torrent to download it.

After the download has completed extract the archive

#### Image your SD Card

These instructions are for macOS. Installation instructions are available [on the Raspberry Pi website](https://www.raspberrypi.org/documentation/installation/installing-images/README.md) for other platforms.

1. Insert your SD Card into your Macbook
2. Open Terminal
3. Run `diskutil list` and identify the disk for your SD card. Mine is `/dev/disk5` today. Sub the `5` for your disk number.
4. `diskutil unmountDisk /dev/disk5`
5. `cd ~/Downloads`  (or the directory where your `.img` file is located)
6. `sudo dd bs=1m if=2016-09-23-raspbian-jessie-lite.img of=/dev/rdisk5`
7. Enter your password when prompted (due to the `sudo`)
8. Wait - It took 1 minute and 19 seconds for me.
9. Add an empty file named 'ssh' to the boot partition: `touch /Volumes/boot/ssh`
10. `diskutil eject /dev/disk5`
11. Remove your SD Card from you laptop and insert in your Raspberry Pi

### Update and Configure Pi

1. Connect the Pi to your network, and apply power so it boots.
2. Determine the IP address of the Pi (I'll leave the deatils of this to you)
3. SSH into your Pi with `ssh pi@192.168.12.206`  (default password is `raspberry`)
4. `sudo apt-get update && sudo apt-get upgrade -y`
5. `sudo raspi-config` Perform these actions in raspi-config:
  * Expand Filesystem
  * Change User Password
  * Localisation Options
    * Change Locale
      * Select `en_US.UTF-8 UTF-8` and Deselect `en_GB.UTF-8 UTF-8` (space toggles)
      * Set the default to `en_US.UTF-8` when prompted
    * Change Timezone
  * Advanced
    * Hostname
  * Finish
    * select `Yes` to reboot the Pi when prompted

### Simplify SSH
If you already have a public key and are familiar with how passwordless ssh access works, then this is easy. If you don't, you might want to just skip this. I'm not going to explain how to set up a public key.

On your local computer (NOT THE PI!) run: `ssh-copy-id pi@192.168.12.206`

You should now be able to SSH into the Pi without a password: `ssh pi@192.168.12.206`

## Installation

### Prerequisites

You must have `git` installed on your pi. You can install it with

    sudo apt-get install git -y

Clone this repository into your home directory

    git clone https://github.com/mcfadden/PiSetup.git ~/PiSetup


### Usage

Run the setup script and select which items you wish to install

    sudo ~/PiSetup/setup.sh

At this time, these items are available:

- [ruby](#ruby)
- [PostgreSQL](#postgresql)
- [NGINX](#nginx)
- [wiringPi](#wiringpi)


## Scripts

### Ruby

**`ruby.sh`**

This ruby install script installs `ruby-build` and `ruby`. It will install ruby to `/usr/local` and become your system ruby.

It detects available versions provided by `ruby-build` and defaults to the latests stable build. You will be prompted to select a version.

It disables RDoc for the ruby install, and globally disables docs for gem installation as well.

### PostgreSQL

**`psql.sh`**

This PostgreSQL install script installs `postgres-9.4` and performs a few configuration changes.

It changes the authentication method from `peer` to `md5` which simplifies connecting via a rails app.

It creates a user `rails` with password `rails`. Since we won't allow access to the database except via `localhost` this is safe enough.

It also creates a user `root` with no password. You can set up a password for this user if you desire.

### NGINX

**`nginx.sh`**

Installs and starts NGINX. You will need to configure it for your needs.

### WiringPi

**`wiringPi.sh`**

[WiringPi](http://wiringpi.com) is a GPIO access library for the Raspberry Pi. It includes a command line utility `gpio`.

See [http://wiringpi.com](http://wiringpi.com) for usage instructions.




### Todo:
* Redis
