#!/data/data/com.termux/files/usr/bin/bash

set -e

echo -e "\033[1;32m[Runix Installer]\033[0m Starting install..."

# Create Runix directory
mkdir -p "$HOME/Runix"
cd "$HOME/Runix" || exit 1

# Download latest Runix script
echo -e "\033[1;32m[Runix]\033[0m Downloading Runix..."
curl -s -o Runix "https://raw.githubusercontent.com/Peace-forever69/Runix/main/Runix"
chmod +x Runix

# Create shortcut in ~/bin
mkdir -p "$HOME/bin"
ln -sf "$HOME/Runix/Runix" "$HOME/bin/run"

echo -e "\033[1;32m[Runix]\033[0m Installation complete!"
echo -e "\033[1;32m[Runix]\033[0m Type \033[1;36mrun help\033[0m to get started."