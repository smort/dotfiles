#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "--- brew Setup Script ---"

echo "Checking if brew is installed..."
if ! command -v brew &> /dev/null; then
    echo "brew not found. Continuing with install..."

    /bin/bash -c "NONINTERACTIVE=1 $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "brew is already installed"
fi
