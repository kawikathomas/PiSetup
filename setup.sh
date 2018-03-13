#!/bin/bash

if (( $EUID != 0 )); then
  whiptail --title "PiSetup" --msgbox "    Error - Must be run as root." 10 40
  exit
fi

choices=$(whiptail --title "PiSetup" --notags --checklist "Select the items you wish to install. They will be installed in the order listed here." 20 60 6 \
  ruby.sh "Ruby (latest stable)" off \
  psql.sh "PostgreSQL" off \
  wiringPi.sh "WiringPi" off \
  nginx.sh "NGINX" off \
  rails_misc.sh "Rails Misc (see README)" off \
  3>&1 1>&2 2>&3)

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for choice in $choices; do
  # Remove the quotes that whiptail gives us:
  temp="${choice%\"}"
  temp="${temp#\"}"

  ${DIR}/scripts/${temp}
done
