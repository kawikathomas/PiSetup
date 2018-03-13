#!/bin/bash

if (( $EUID != 0 )); then
  echo "Error: Must be run as root."
  exit
fi

bold=$(tput bold)
normal=$(tput sgr0)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

appName=$(whiptail --title "PiSetup" --inputbox "What is the name of your Rails App?\n\nThis will be used in config files and as directory names.\n\nUnsafe characters will be removed" 20 60 "$(hostname)-rails" 3>&1 1>&2 2>&3)

# Well this is a mouthful.
# sed converts CamelCase into snake_case. Then we convert any spaces into _.    Here we're dowcasing     and finally removing any characters we don't want. Then last we remove duplicate underscores.
safeAppName=$(echo $appName | sed 's/\([a-z0-9]\)\([A-Z]\)/\1_\L\2/g' | tr -s [:space:] '_' | tr [:upper:] [:lower:] | tr -d -c '[:alnum:]_' | tr -s _  | sed 's/_$//')

railsEnv=$(whiptail --title "PiSetup" --notags --menu "What RAILS_ENV and RACK_ENV?" 20 60 4 production "production" staging "staging" development "development" 3>&1 1>&2 2>&3)

if [[ $railsEnv != "" ]]; then
  echo "RAILS_ENV=$railsEnv" | sudo tee -a /etc/environment
  echo "RACK_ENV=$railsEnv" | sudo tee -a /etc/environment
fi

currentUser=$(logname)

# Create the directory structure for the app:
# /www/safeAppName
sudo mkdir /www
sudo chown $currentUser:$currentUser /www
sudo -i -u $currentUser mkdir /www/$safeAppName

webServer=$(whiptail --title "PiSetup" --notags --menu "What webserver will you use for $appName?\n\nWe use this to configure systemd and Nginx (if installed)" 20 60 4 puma "Puma" unicorn "Unicorn" none "Other / None" 3>&1 1>&2 2>&3)

if [[ $webServer = "puma" ]]; then
  webserverSystemd="puma Puma off"
elif [[ $webServer = "unicorn" ]]; then
  webserverSystemd="unicorn Unicorn off"
fi

systemdChoices=$(whiptail --title "PiSetup" --notags --checklist "Which systemd scripts should we setup?" 20 60 4 \
  sidekiq "Sidekiq" off \
  clockwork "Clockwork" off \
  ${webserverSystemd} \
  3>&1 1>&2 2>&3)


for choice in $systemdChoices; do
  # Remove the quotes that whiptail gives us:
  temp="${choice%\"}"
  choice="${temp#\"}"

  if [[ $choice = "sidekiq" ]]; then
    echo "Setting up sidekiq systemd script"
    sed -e "s/<<safeAppName>>/$safeAppName/g;s/<<environment>>/$railsEnv/g" ${DIR}/../templates/systemd/sidekiq.service > /lib/systemd/system/sidekiq.service
    echo "Created /lib/systemd/system/sidekiq.service"
  elif [[ $choice = "clockwork" ]]; then
    echo "Setting up clockwork systemd script"
    sed -e "s/<<safeAppName>>/$safeAppName/g;s/<<environment>>/$railsEnv/g" ${DIR}/../templates/systemd/clockwork.service > /lib/systemd/system/clockwork.service
    echo "Created /lib/systemd/system/clockwork.service"
  elif [[ $choice = "puma" ]]; then
    echo "Setting up puma systemd script"
    sed -e "s/<<safeAppName>>/$safeAppName/g;s/<<environment>>/$railsEnv/g" ${DIR}/../templates/systemd/puma.service > /lib/systemd/system/puma.service
    echo "Created /lib/systemd/system/puma.service"
  elif [[ $choice = "unicorn" ]]; then
    echo "Setting up unicorn systemd script"
    sed -e "s/<<safeAppName>>/$safeAppName/g;s/<<environment>>/$railsEnv/g" ${DIR}/../templates/systemd/unicorn.service > /lib/systemd/system/unicorn.service
    echo "Created /lib/systemd/system/unicorn.service"
  fi
done
echo "Review the systemd configurations created above, and then enable them with (ex:) 'systemctl enable service.service'"

if which nginx > /dev/null; then
  # Nginx is installed!
  if (whiptail --title "PiSetup" --yesno "Create nginx site configuration for $appName?" 10 60); then
    # This is as simple as piping a templated file through sed to replace some config settings,
    # and then unlinking `sites-enabled/default` and linking `sites-enabled/this-one`
    sed -e "s/<<safeAppName>>/$safeAppName/g" ${DIR}/../templates/nginx.conf > /etc/nginx/sites-available/$safeAppName.conf
    sudo rm /etc/nginx/sites-enabled/default
    sudo ln -s /etc/nginx/sites-available/$safeAppName.conf /etc/nginx/sites-enabled
  fi
fi


gemChoices=$(whiptail --title "PiSetup" --notags --checklist "Which system gems should we install?" 20 60 4 \
  bundler "bundler" on \
  therubyracer "therubyracer" off \
  3>&1 1>&2 2>&3)

for gem in $gemChoices; do
  # Remove the quotes that whiptail gives us:
  temp="${gem%\"}"
  temp="${temp#\"}"

  sudo -i -u $currentUser gem install $temp
done


if (whiptail --title "PiSetup" --yesno "Setup Logrotate for all log files in /www/$safeAppName/log ?" 10 60); then
  sed -e "s/<<safeAppName>>/$safeAppName/g" ${DIR}/../templates/logrotate.conf> /etc/logrotate.d/$safeAppName.conf
fi


#TODO: Prompt for URL to clone from? Maybe just github username/repo.git
  # Clone
  # Run bundle install
  # prompt to run `bundle exec rake db:create && bundle exec rake db:migrate`


if (whiptail --title "PiSetup" --yesno "Reboot Raspberry Pi? (Recommended)" 10 60); then
  whiptail --title "Reboot" --msgbox "The system will reboot." 8 78
	reboot
fi
