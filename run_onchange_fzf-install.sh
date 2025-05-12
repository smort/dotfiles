#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "--- fzf Installation Script ---"

FZF_VERSION="0.62.0"
FZF_FILENAME="fzf-${FZF_VERSION}-linux_amd64.tar.gz"
FZF_URL="https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/${FZF_FILENAME}"
INSTALL_DIR="$HOME/.local/bin"
FZF_BINARY_PATH="$INSTALL_DIR/fzf"

# Trap to clean up the temporary directory on exit
trap 'rm -rf "$MKTEMP_DIR"' EXIT

echo "Checking if fzf is installed at $FZF_BINARY_PATH..."
if [[ ! -f "$FZF_BINARY_PATH" ]]; then
    echo "fzf not found. Downloading and installing v${FZF_VERSION}..."

    # Create a temporary directory
    MKTEMP_DIR=$(mktemp -d)
    echo "Using temporary directory: $MKTEMP_DIR"

    # Navigate into the temporary directory
    cd "$MKTEMP_DIR"

    # Download the tarball
    echo "Downloading $FZF_URL..."
    curl -L -o "$FZF_FILENAME" "$FZF_URL" # -L follows redirects

    # Unpack the tarball
    echo "Unpacking $FZF_FILENAME..."
    tar -xzf "$FZF_FILENAME"

    # Create the installation directory if it doesn't exist
    mkdir -p "$INSTALL_DIR"

    # Move the fzf binary to the installation directory
    echo "Moving fzf binary to $INSTALL_DIR..."
    mv fzf "$INSTALL_DIR/"

    echo "fzf v${FZF_VERSION} installed successfully to $FZF_BINARY_PATH."

    # Clean up temporary directory is handled by the trap
else
    echo "fzf is already installed at $FZF_BINARY_PATH."
fi

echo "--- fzf Installation Complete ---"
