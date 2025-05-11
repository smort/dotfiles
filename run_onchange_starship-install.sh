#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "--- Starship Setup Script ---"
echo "Checking if Starship is installed..."
if ! command -v starship &> /dev/null; then
    echo "Starship not found. Installing the latest version using the official script..."
    # Use the recommended curl | sh install script
    # -s: silent
    # -S: show errors
    curl -sS https://starship.rs/install.sh | sh

    echo "Starship installed successfully."
else
    echo "Starship is already installed."
fi

