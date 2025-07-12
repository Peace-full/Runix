#!/data/data/com.termux/files/usr/bin/bash

set -e

echo -e "\033[1;32m[Runix Installer]\033[0m Starting install..."

# Create folders
mkdir -p "$HOME/Runix"
mkdir -p "$HOME/bin"

# Download the latest Runix script
echo -e "\033[1;32m[Runix]\033[0m Downloading Runix..."
curl -s -o "$HOME/Runix/Runix" "https://raw.githubusercontent.com/Peace-forever69/Runix/main/Runix"
chmod +x "$HOME/Runix/Runix"

# Create shortcut in ~/bin
ln -sf "$HOME/Runix/Runix" "$HOME/bin/run"

# Ensure $HOME/bin is in PATH
if ! echo "$PATH" | grep -q "$HOME/bin"; then
    echo -e "\033[1;32m[Runix]\033[0m Adding \$HOME/bin to PATH in ~/.bashrc..."
    if [ ! -f "$HOME/.bashrc" ]; then
        touch "$HOME/.bashrc"
    fi
    grep -qxF 'export PATH=$HOME/bin:$PATH' "$HOME/.bashrc" || echo 'export PATH=$HOME/bin:$PATH' >> "$HOME/.bashrc"
    source "$HOME/.bashrc"
fi

echo -e "\033[1;32m[Runix]\033[0m Installation complete!"
echo -e "\033[1;32m[Runix]\033[0m Type \033[1;36mrun help\033[0m to get started."