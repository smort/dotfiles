#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "--- fnm Installation Script ---"

echo "Checking if fnm is installed..."
# The fnm install script typically places the binary in ~/.fnm/fnm
# and recommends sourcing a shell-specific file to add it to the PATH.
# We check if the 'fnm' command is available in the current PATH.
if ! command -v fnm &> /dev/null; then
    echo "fnm not found. Installing using the official script..."
    # Use the official curl | bash install script
    # -f: Fail silently on server errors
    # -s: Silent mode
    # -S: Show error despite -s
    # -L: Follow redirects
    curl -fsSL https://fnm.vercel.app/install | bash

    echo "fnm installation script executed."
    echo "The fnm binary should be in ~/.fnm/fnm and shell setup files created in ~/.fnm."
else
    echo "fnm is already installed (command found in PATH)."
fi

echo "--- fnm Installation Complete ---"

