# Raspberry Pi Setup

## Preparation

This section covers the basics of getting your Pi up and running. It's mostly in place for my own documentation.

If you already have a working Pi and just want to use the Setup Scripts, jump to the [Installation](#installation) section below.

### Image your SD Card

#### Obtain the latest version of Raspbian

Visit the [Raspbian Download Page](https://www.raspberrypi.org/downloads/raspbian/) and download the latest version. I recommend **Jessie Lite** and using the torrent to download it.

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
9. `diskutil eject /dev/disk5`
10. Remove your SD Card from you laptop and insert in your Raspberry Pi

### Update and Configure Pi

1. Connect the Pi to your network, and apply power so it boots.
2. Determine the IP address of the Pi (I'll leave the deatils of this to you)
3. SSH into your Pi with `ssh pi@192.168.12.206`  (default password is `raspberry`)
4. `sudo apt-get update && sudo apt-get upgrade -y`
5. `sudo raspi-config` Perform these actions in raspi-config:
  * Expand Filesystem
  * Change User Password
  * Internationalization Options
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

You must have `git` installed on your pi. You can install it with `sudo apt-get install git -y`

Clone this repository in your home directory