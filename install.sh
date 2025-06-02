#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

./install-fish.sh
./install-apt-packages.sh
./install-brew.sh
./install-brew-packages.sh
