#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

PACKAGE_FILE="brew-packages.conf"

if [ ! -f "$PACKAGE_FILE" ]; then
  echo "File not found: $PACKAGE_FILE"
  exit 1
fi

echo "Updating Homebrew..."
brew update

while IFS= read -r package || [ -n "$package" ]; do
  # Skip empty lines and comments
  [[ -z "$package" || "$package" =~ ^# ]] && continue

  if brew list --formula | grep -qx "$package"; then
    echo "Already installed: $package"
  else
    echo "Installing: $package"
    brew install "$package"
  fi
done < "$PACKAGE_FILE"
