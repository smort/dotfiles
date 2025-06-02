#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

PACKAGE_FILE="apt-packages.conf"

if [ ! -f "$PACKAGE_FILE" ]; then
  echo "File not found: $PACKAGE_FILE"
  exit 1
fi

echo "Updating package index..."
sudo apt update

while IFS= read -r package || [ -n "$package" ]; do
  # Skip empty lines and comments
  [[ -z "$package" || "$package" =~ ^# ]] && continue

  if dpkg -s "$package" &> /dev/null; then
    echo "Already installed: $package"
  else
    echo "Installing: $package"
    sudo apt install -y "$package"
  fi
done < "$PACKAGE_FILE"
