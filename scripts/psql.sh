#!/bin/bash

if (( $EUID != 0 )); then
  echo "Error: Must be run as root."
  exit
fi

bold=$(tput bold)
normal=$(tput sgr0)

echo "This will install PostgreSQL."

read -p "Do you wish to proceed? (y/n) " continue
if [[ $continue != "y" ]]; then
  echo -e "\nHave a good day!"
  exit
fi

sudo apt-get update
sudo apt-get install -y postgresql-9.4 postgresql-contrib-9.4 libpq-dev

psqlVersion=$(psql --version | grep -o '[2-9]\.[0-9].[0-9]$')
echo "Installed PostgreSQL version $psqlVersion"

echo "Configuring..."

# Backup the psql config file, then change the connect method to md5
sudo cp /etc/postgresql/9.4/main/pg_hba.conf /etc/postgresql/9.4/main/pg_hba.conf.backup
sudo sed -i -r "s/(^local[ \t]+all[ \t]+all[ \t]+)peer$/\1md5/" /etc/postgresql/9.4/main/pg_hba.conf

# Restart postgres to load that configuration
sudo service postgresql restart

# Add some users
sudo -u postgres bash -c "psql -c \"CREATE ROLE rails WITH PASSWORD 'rails' SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN;\""
echo "Created database role 'rails' with password 'rails'";

sudo -u postgres bash -c "psql -c \"CREATE ROLE root SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN;\""
echo "Created database role 'root' with no password";

echo "${bold}You can get to a psql console with 'psql -U rails -d postgres'${normal}"


echo "Installed PostgreSQL version $psqlVersion"