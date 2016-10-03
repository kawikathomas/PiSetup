#!/bin/bash

if (( $EUID != 0 )); then
  echo "Error: Must be run as root."
  exit
fi

echo -e "PostgreSQL Install is in development. Check https://github.com/mcfadden/PiSetup for the latest.\n\n\n"

exit