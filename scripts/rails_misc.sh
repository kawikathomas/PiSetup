#!/bin/bash

if (( $EUID != 0 )); then
  echo "Error: Must be run as root."
  exit
fi

bold=$(tput bold)
normal=$(tput sgr0)

appName=$(whiptail --title "PiSetup" --inputbox "What is the name of your Rails App?\n\nThis will be used in config files and as directory names.\n\nUnsafe characters will be removed" 20 60 "$(hostname)-rails" 3>&1 1>&2 2>&3)

# Well this is a mouthful.
# sed converts CamelCase into snake_case. Then we convert any spaces into _.    Here we're dowcasing     and finally removing any characters we don't want. Then last we remove duplicate underscores.
safeAppName=$(echo $appName | sed 's/\([a-z0-9]\)\([A-Z]\)/\1_\L\2/g' | tr -s [:space:] '_' | tr [:upper:] [:lower:] | tr -d -c '[:alnum:]_' | tr -s _ )

# Create the directory structure for the app:
# /www/safeAppName/current
sudo mkdir /www
sudo chown $(logname):$(logname) /www
sudo -i $(logname) mkdir /www/$safeAppName
sudo -i $(logname) mkdir /www/$safeAppName/current

webServer=$(whiptail --title "PiSetup" --notags --menu "What webserver will you use for $appName?\n\nWe use this to configure Upstart and Nginx (if installed)" 20 60 4 puma "Puma" unicorn "Unicorn" none "Other / None" 3>&1 1>&2 2>&3)

if which initctl > /dev/null; then
  # Upstart is installed!

  if [[ $webServer = "puma" ]]; then
    webserverUpstart="puma Puma off"
  elif [[ $webServer = "unicorn" ]]; then
    webserverUpstart="unicorn Unicorn off"
  fi

  upstartChoices=$(whiptail --title "PiSetup" --notags --checklist "Which Upstart scripts should we setup?" 20 60 4 \
    sidekiq "Sidekiq" off \
    clockwork "Clockwork" off \
    ${webserverUpstart} \
    3>&1 1>&2 2>&3)


  for choice in $upstartChoices; do
    if [[ $choice = "sidekiq" ]]; then
      echo "Setting up sidekiq Upstart script"
      sed -e "s/<<safeAppName>>/$safeAppName/g" ../templates/upstart/sidekiq.conf > /etc/init/sidekiq.conf
    elif [[ $choice = "clockwork" ]]; then
      echo "Setting up clockwork Upstart script"
      sed -e "s/<<safeAppName>>/$safeAppName/g" ../templates/upstart/clockwork.conf > /etc/init/clockwork.conf
    elif [[ $choice = "puma" ]]; then
      echo "Setting up puma Upstart script"
      sed -e "s/<<safeAppName>>/$safeAppName/g" ../templates/upstart/puma.conf > /etc/init/puma.conf
    elif [[ $choice = "unicorn" ]]; then
      echo "Setting up unicorn Upstart script"
      sed -e "s/<<safeAppName>>/$safeAppName/g" ../templates/upstart/unicorn.conf > /etc/init/unicorn.conf
    fi
  done

    # Output the path to the files we create and tell user to review them
else
  whiptail --title "PiSetup" --msgbox "Unable to configure Upstart scripts: Upstart not detected." 10 40
fi

if which nginx > /dev/null; then
  # Nginx is installed!
  if (whiptail --title "PiSetup" --yesno "Create nginx site configuration for $appName?" 10 60); then
    # This is as simple as piping a templated file through sed to replace some config settings,
    # and then unlinking `sites-enabled/default` and linking `sites-enabled/this-one`
    sed -e "s/<<safeAppName>>/$safeAppName/g" ../templates/nginx.conf> /etc/nginx/sites-available/$safeAppName.conf
    sudo rm /etc/nginx/sites-enabled/default
    sudo ln -s /etc/nginx/sites-available/$safeAppName.conf /etc/nginx/sites-enabled
  fi
fi


gemChoices=$(whiptail --title "PiSetup" --notags --checklist "Which system gems should we install?" 20 60 4 \
  bundler "bundler" on \
  therubyracer "therubyracer" off \
  3>&1 1>&2 2>&3)

for gem in $gemChoices; do
  sudo -i $(logname) gem install $gem
fi


if (whiptail --title "PiSetup" --yesno "Setup Logrotate for all log files in /www/$safeAppName/current/log ?" 10 60); then
  sed -e "s/<<safeAppName>>/$safeAppName/g" ../templates/logrotate.conf> /etc/logrotate.d/$safeAppName.conf
fi


railsEnv=$(whiptail --title "PiSetup" --notags --menu "What RAILS_ENV and RACK_ENV?" 20 60 4 production "production" staging "Staging" development "development" '' "none" 3>&1 1>&2 2>&3)

if [[ $railsEnv != "" ]]; then
  echo "RAILS_ENV=$railsEnv" | sudo tee -a /etc/environment
  echo "RACK_ENV=$railsEnv" | sudo tee -a /etc/environment
fi

#TODO: Prompt for URL to clone from? Maybe just github username/repo.git
  # Clone
  # Run bundle install
  # prompt to run `bundle exec rake db:create && bundle exec rake db:migrate`

#TODO: Prompt to cleanup "current" folder if you'll be deploying with capistrano
# If yes to capistrano, output the IP address of this device.


if (whiptail --title "PiSetup" --yesno "Reboot Raspberry Pi? (Recommended)" 10 60); then
  whiptail --title "Reboot" --msgbox "The system will reboot." 8 78
	reboot
fi
