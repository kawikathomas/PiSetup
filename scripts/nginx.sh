#!/bin/bash

if (( $EUID != 0 )); then
  echo "Error: Must be run as root."
  exit
fi

bold=$(tput bold)
normal=$(tput sgr0)

echo "This will install NGINX"

read -p "Do you wish to proceed? (y/n) " continue
if [[ $continue != "y" ]]; then
  echo -e "\nHave a good day!"
  exit
fi

sudo apt-get update
sudo apt-get install -y nginx

echo "Installed NGINX"