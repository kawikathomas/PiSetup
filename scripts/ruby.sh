#!/bin/bash

if (( $EUID != 0 )); then
  echo "Error: Must be run as root."
  exit
fi

bold=$(tput bold)
normal=$(tput sgr0)

echo "This will install ruby-build and ruby. ${bold}This will become your system version of ruby${normal}"

read -p "Do you wish to proceed? (y/n) " continue
if [[ $continue != "y" ]]; then
  echo -e "\nHave a good day!"
  exit
fi

echo "Installing ruby-build"


# Set up the recommended build environment https://github.com/rbenv/ruby-build/wiki#suggested-build-environment
sudo apt-get update
apt-get install -y autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev

# Install ruby-build
git clone https://github.com/rbenv/ruby-build.git ~/ruby-build
cd ~/ruby-build
./install.sh

# Prompt for Ruby Version
lastVersion=$(ruby-build --definitions | grep '^[2-9]\.[0-9].[0-9]$' | tail -1)

echo "What verson of Ruby would you like to install? (Anything available in 'ruby-build --definitions' will work.)"

read -p "  Ruby Version: (${lastVersion}) " installVersion
if [[ $installVersion == "" ]]; then installVersion=${lastVersion}; fi;

echo "Installing Ruby Version: ${installVersion}"

# bye bye RDoc
CONFIGURE_OPTS="--disable-install-doc --enable-shared" ruby-build --verbose ${installVersion} /usr/local
# No docs for gems either
echo "gem: --no-document" > ~/.gemrc

echo "Installed Ruby Version: ${installVersion}"