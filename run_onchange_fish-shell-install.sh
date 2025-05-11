#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "--- Fish Shell Setup Script ---"

# 1. Install fish shell if not already installed (using PPA for latest version)
echo "Checking if fish is installed..."
if ! command -v fish &> /dev/null; then
    echo "fish not found. Attempting to install the latest version via PPA..."

    # Add the official fish shell PPA
    echo "Adding fish shell PPA..."
    # Need software-properties-common to use add-apt-repository
    sudo apt update
    sudo apt install software-properties-common -y
    sudo add-apt-repository ppa:fish-shell/release-4 -y

    # Update package list again to include packages from the new PPA
    echo "Updating apt package list after adding PPA..."
    sudo apt update

    # Install fish from the PPA
    echo "Installing fish from PPA..."
    sudo apt install fish -y

    echo "fish installed successfully via PPA."
else
    echo "fish is already installed."
fi

# Get the path to the fish executable - now guaranteed to be available if script continues
FISH_PATH=$(command -v fish)

# 2. Set fish as the default shell if it's not already the default
echo "Checking current default shell..."
if [[ "$SHELL" != "$FISH_PATH" ]]; then
    echo "Your default shell is $SHELL."
    echo "Setting fish ($FISH_PATH) as the default shell..."
    # Use chsh to change the default shell.
    # This typically requires entering your password.
    # The change usually takes effect on your next login.
    chsh -s "$FISH_PATH"

    echo "Default shell set to fish. Please log out and log back in for the change to take effect."
else
    echo "fish is already your default shell."
fi

# 3. Initialize config.fish if it doesn't exist
FISH_CONFIG_DIR="$HOME/.config/fish"
FISH_CONFIG_FILE="$FISH_CONFIG_DIR/config.fish"

echo "Checking for fish configuration file ($FISH_CONFIG_FILE)..."
if [[ ! -f "$FISH_CONFIG_FILE" ]]; then
    echo "config.fish not found. Creating a basic config.fish..."
    # Create the directory if it doesn't exist
    mkdir -p "$FISH_CONFIG_DIR"
    # Create a basic config file with a comment
    echo "# Initial fish configuration" > "$FISH_CONFIG_FILE"
    echo "Basic config.fish created."
else
    echo "config.fish already exists."
fi

echo "--- Fish Shell Setup Complete ---"
