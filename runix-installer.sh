#!/usr/bin/env bash
# Runix Universal Installer
# Cross-platform installation script for Linux, macOS, Windows (Git Bash/WSL), and Android Termux
# https://github.com/Peace-forever69/Runix

set -e

# Colors
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GRN='\033[0;32m'
    YEL='\033[1;33m'
    BLU='\033[0;34m'
    CYAN='\033[1;36m'
    MAG='\033[0;35m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED='' GRN='' YEL='' BLU='' CYAN='' MAG='' BOLD='' NC=''
fi

# Version
VERSION="2.0.0"
REPO_URL="https://raw.githubusercontent.com/Peace-forever69/Runix/main"
GITHUB_REPO="https://github.com/Peace-forever69/Runix"

# Banner
show_banner() {
    clear
    echo -e "${GRN}
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║    ██████╗ ██╗   ██╗███╗   ██╗██╗██╗  ██╗                ║
║    ██╔══██╗██║   ██║████╗  ██║██║╚██╗██╔╝                ║
║    ██████╔╝██║   ██║██╔██╗ ██║██║ ╚███╔╝                 ║
║    ██╔══██╗██║   ██║██║╚██╗██║██║ ██╔██╗                 ║
║    ██║  ██║╚██████╔╝██║ ╚████║██║██╔╝ ██╗                ║
║    ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝                ║
║                                                            ║
║            ${BOLD}Universal Installer v${VERSION}${NC}${GRN}                   ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
${NC}"
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)
            if [[ -d "/data/data/com.termux" ]]; then
                OS="termux"
                OS_DISPLAY="Android Termux"
            elif grep -qi microsoft /proc/version 2>/dev/null; then
                OS="wsl"
                OS_DISPLAY="Windows Subsystem for Linux"
            else
                OS="linux"
                OS_DISPLAY="Linux"
            fi
            ;;
        Darwin*)
            OS="macos"
            OS_DISPLAY="macOS"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            OS="windows"
            OS_DISPLAY="Windows (Git Bash)"
            ;;
        *)
            OS="unknown"
            OS_DISPLAY="Unknown OS"
            ;;
    esac
}

# Detect architecture
detect_arch() {
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64|amd64) ARCH_DISPLAY="x86_64" ;;
        aarch64|arm64) ARCH_DISPLAY="ARM64" ;;
        armv7l|armv8l) ARCH_DISPLAY="ARM" ;;
        i386|i686) ARCH_DISPLAY="x86" ;;
        *) ARCH_DISPLAY="$ARCH" ;;
    esac
}

# Check if running as root (not recommended for user installations)
check_root() {
    if [[ $EUID -eq 0 ]] && [[ "$OS" != "termux" ]]; then
        echo -e "${YEL}⚠️  Running as root is not recommended for user installations.${NC}"
        echo -e "${YEL}   Consider running as a regular user unless installing system-wide.${NC}"
        echo -ne "${BLU}Continue anyway? (y/n): ${NC}"
        read -r response
        [[ ! "$response" =~ ^[yY]$ ]] && exit 1
    fi
}

# Show system info
show_system_info() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}System Information${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  Operating System : ${GRN}$OS_DISPLAY${NC}"
    echo -e "${CYAN}║${NC}  Architecture     : ${GRN}$ARCH_DISPLAY${NC}"
    echo -e "${CYAN}║${NC}  Shell            : ${GRN}${SHELL##*/}${NC}"
    echo -e "${CYAN}║${NC}  User             : ${GRN}$(whoami)${NC}"
    echo -e "${CYAN}║${NC}  Home Directory   : ${GRN}$HOME${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Check internet connection
check_internet() {
    echo -ne "${BLU}🌐 Checking internet connection... ${NC}"
    
    if command -v curl >/dev/null 2>&1; then
        if curl -sf --connect-timeout 5 "$GITHUB_REPO" >/dev/null 2>&1; then
            echo -e "${GRN}✓${NC}"
            return 0
        fi
    elif command -v wget >/dev/null 2>&1; then
        if wget -q --spider --timeout=5 "$GITHUB_REPO" 2>/dev/null; then
            echo -e "${GRN}✓${NC}"
            return 0
        fi
    fi
    
    echo -e "${RED}✗${NC}"
    echo -e "${RED}❌ No internet connection detected${NC}"
    echo -e "${YEL}Please check your connection and try again${NC}"
    exit 1
}

# Check dependencies
check_dependencies() {
    echo -e "${BLU}📦 Checking dependencies...${NC}"
    
    local missing_deps=()
    
    # Check for download tools
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        missing_deps+=("curl or wget")
    fi
    
    # Check for bash
    if ! command -v bash >/dev/null 2>&1; then
        missing_deps+=("bash")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Missing required dependencies:${NC}"
        for dep in "${missing_deps[@]}"; do
            echo -e "   - $dep"
        done
        echo
        echo -e "${YEL}Please install missing dependencies and try again${NC}"
        exit 1
    fi
    
    echo -e "${GRN}✓ All required dependencies found${NC}"
}

# Setup installation directories
setup_directories() {
    case "$OS" in
        termux)
            INSTALL_DIR="$HOME/Runix"
            BIN_DIR="$PREFIX/bin"
            CONFIG_DIR="$HOME/Runix"
            ;;
        linux|wsl)
            if [[ "$INSTALL_TYPE" == "system" ]]; then
                INSTALL_DIR="/usr/local/share/runix"
                BIN_DIR="/usr/local/bin"
                CONFIG_DIR="$HOME/.config/runix"
            else
                INSTALL_DIR="$HOME/.local/share/runix"
                BIN_DIR="$HOME/.local/bin"
                CONFIG_DIR="$HOME/.config/runix"
            fi
            ;;
        macos)
            if [[ "$INSTALL_TYPE" == "system" ]]; then
                INSTALL_DIR="/usr/local/share/runix"
                BIN_DIR="/usr/local/bin"
                CONFIG_DIR="$HOME/.config/runix"
            else
                INSTALL_DIR="$HOME/.local/share/runix"
                BIN_DIR="$HOME/.local/bin"
                CONFIG_DIR="$HOME/.config/runix"
            fi
            ;;
        windows)
            INSTALL_DIR="$HOME/Runix"
            BIN_DIR="$HOME/bin"
            CONFIG_DIR="$HOME/Runix"
            ;;
        *)
            INSTALL_DIR="$HOME/Runix"
            BIN_DIR="$HOME/bin"
            CONFIG_DIR="$HOME/Runix"
            ;;
    esac
    
    echo -e "${BLU}📁 Installation directories:${NC}"
    echo -e "   Program : ${CYAN}$INSTALL_DIR${NC}"
    echo -e "   Binary  : ${CYAN}$BIN_DIR${NC}"
    echo -e "   Config  : ${CYAN}$CONFIG_DIR${NC}"
    echo
}

# Choose installation type
choose_install_type() {
    if [[ "$OS" == "termux" || "$OS" == "windows" ]]; then
        INSTALL_TYPE="user"
        return
    fi
    
    echo -e "${YEL}🔧 Choose installation type:${NC}"
    echo -e "   ${GRN}[1]${NC} User installation (recommended) - No sudo required"
    echo -e "   ${GRN}[2]${NC} System-wide installation - Requires sudo"
    echo
    echo -ne "${BLU}Enter choice [1-2] (default: 1): ${NC}"
    read -r choice
    
    case "$choice" in
        2)
            INSTALL_TYPE="system"
            if ! command -v sudo >/dev/null 2>&1; then
                echo -e "${RED}❌ sudo not found. Cannot perform system-wide installation${NC}"
                echo -e "${YEL}Falling back to user installation${NC}"
                INSTALL_TYPE="user"
            fi
            ;;
        *)
            INSTALL_TYPE="user"
            ;;
    esac
    
    echo
}

# Download Runix
download_runix() {
    echo -e "${BLU}⬇️  Downloading Runix...${NC}"
    
    local script_url="${REPO_URL}/Runix"
    local tmp_file
    tmp_file="$(mktemp -t runix.XXXXXX 2>/dev/null || mktemp)"
    
    if command -v curl >/dev/null 2>&1; then
        if curl -fsSL "$script_url" -o "$tmp_file"; then
            echo -e "${GRN}✓ Downloaded successfully${NC}"
        else
            echo -e "${RED}❌ Download failed${NC}"
            rm -f "$tmp_file"
            exit 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if wget -q "$script_url" -O "$tmp_file"; then
            echo -e "${GRN}✓ Downloaded successfully${NC}"
        else
            echo -e "${RED}❌ Download failed${NC}"
            rm -f "$tmp_file"
            exit 1
        fi
    fi
    
    DOWNLOADED_SCRIPT="$tmp_file"
}

# Install Runix
install_runix() {
    echo -e "${BLU}📦 Installing Runix...${NC}"
    
    # Create directories
    if [[ "$INSTALL_TYPE" == "system" ]]; then
        sudo mkdir -p "$INSTALL_DIR" "$BIN_DIR" "$CONFIG_DIR"
    else
        mkdir -p "$INSTALL_DIR" "$BIN_DIR" "$CONFIG_DIR"
    fi
    
    # Copy script
    local install_path="$INSTALL_DIR/runix"
    
    if [[ "$INSTALL_TYPE" == "system" ]]; then
        sudo cp "$DOWNLOADED_SCRIPT" "$install_path"
        sudo chmod +x "$install_path"
        sudo ln -sf "$install_path" "$BIN_DIR/runix"
        sudo ln -sf "$install_path" "$BIN_DIR/run"
    else
        cp "$DOWNLOADED_SCRIPT" "$install_path"
        chmod +x "$install_path"
        ln -sf "$install_path" "$BIN_DIR/runix"
        ln -sf "$install_path" "$BIN_DIR/run"
    fi
    
    # Clean up
    rm -f "$DOWNLOADED_SCRIPT"
    
    echo -e "${GRN}✓ Installation complete${NC}"
}

# Setup shell configuration
setup_shell() {
    echo -e "${BLU}🐚 Configuring shell...${NC}"
    
    local shell_config=""
    local shell_name="${SHELL##*/}"
    
    case "$shell_name" in
        bash)
            shell_config="$HOME/.bashrc"
            [[ ! -f "$shell_config" ]] && shell_config="$HOME/.bash_profile"
            ;;
        zsh)
            shell_config="$HOME/.zshrc"
            ;;
        fish)
            shell_config="$HOME/.config/fish/config.fish"
            mkdir -p "$(dirname "$shell_config")"
            ;;
        *)
            echo -e "${YEL}⚠️  Unknown shell: $shell_name${NC}"
            echo -e "${YEL}   You may need to manually add $BIN_DIR to PATH${NC}"
            return
            ;;
    esac
    
    # Check if PATH already includes BIN_DIR
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        echo -ne "${BLU}Add $BIN_DIR to PATH in $shell_config? (y/n): ${NC}"
        read -r response
        
        if [[ "$response" =~ ^[yY]$ ]]; then
            if [[ "$shell_name" == "fish" ]]; then
                echo -e "\n# Runix" >> "$shell_config"
                echo "set -gx PATH $BIN_DIR \$PATH" >> "$shell_config"
            else
                echo -e "\n# Runix" >> "$shell_config"
                echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$shell_config"
            fi
            echo -e "${GRN}✓ PATH updated in $shell_config${NC}"
            echo -e "${YEL}⚠️  Run 'source $shell_config' or restart your shell${NC}"
        fi
    else
        echo -e "${GRN}✓ $BIN_DIR already in PATH${NC}"
    fi
}

# OS-specific setup
os_specific_setup() {
    echo -e "${BLU}🔧 OS-specific configuration...${NC}"
    
    case "$OS" in
        termux)
            echo -e "${CYAN}Setting up Termux integration...${NC}"
            
            # Termux storage setup
            if [[ ! -d "$HOME/storage" ]] && command -v termux-setup-storage >/dev/null 2>&1; then
                echo -ne "${BLU}Setup Termux storage access? (y/n): ${NC}"
                read -r response
                if [[ "$response" =~ ^[yY]$ ]]; then
                    termux-setup-storage
                    echo -e "${GRN}✓ Storage access granted${NC}"
                fi
            fi
            
            # Create Termux widget shortcut
            local widget_dir="$HOME/.shortcuts"
            mkdir -p "$widget_dir"
            cat > "$widget_dir/Runix" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
runix help
EOF
            chmod +x "$widget_dir/Runix"
            echo -e "${GRN}✓ Termux widget created${NC}"
            ;;
            
        linux|wsl)
            echo -e "${CYAN}Linux configuration complete${NC}"
            
            if [[ "$INSTALL_TYPE" == "system" ]]; then
                echo -e "${GRN}✓ Installed system-wide${NC}"
            else
                echo -e "${GRN}✓ Installed for user${NC}"
            fi
            ;;
            
        macos)
            echo -e "${CYAN}macOS configuration...${NC}"
            
            # Ask about Spotlight indexing
            echo -ne "${BLU}Enable Spotlight indexing for Runix? (y/n): ${NC}"
            read -r response
            if [[ "$response" =~ ^[yY]$ ]]; then
                mdimport "$INSTALL_DIR" 2>/dev/null || true
                echo -e "${GRN}✓ Spotlight indexing enabled${NC}"
            fi
            ;;
            
        windows)
            echo -e "${CYAN}Windows configuration...${NC}"
            
            # PowerShell profile setup
            local ps_profile="$HOME/Documents/PowerShell/Microsoft.PowerShell_profile.ps1"
            
            if [[ -d "$(dirname "$ps_profile")" ]]; then
                echo -ne "${BLU}Create PowerShell alias? (y/n): ${NC}"
                read -r response
                if [[ "$response" =~ ^[yY]$ ]]; then
                    if ! grep -q "runix" "$ps_profile" 2>/dev/null; then
                        echo "" >> "$ps_profile"
                        echo "# Runix alias" >> "$ps_profile"
                        echo "Set-Alias -Name runix -Value '$BIN_DIR/runix'" >> "$ps_profile"
                        echo -e "${GRN}✓ PowerShell alias created${NC}"
                    fi
                fi
            fi
            
            echo -e "${YEL}⚠️  For Git Bash, PATH is already configured${NC}"
            echo -e "${YEL}⚠️  For CMD/PowerShell, add to System Environment Variables:${NC}"
            echo -e "    ${CYAN}$BIN_DIR${NC}"
            ;;
    esac
}

# Create uninstaller
create_uninstaller() {
    echo -e "${BLU}📝 Creating uninstaller...${NC}"
    
    local uninstall_script="$INSTALL_DIR/uninstall.sh"
    
    cat > "$uninstall_script" << EOF
#!/usr/bin/env bash
# Runix Uninstaller

set -e

RED='\033[0;31m'
GRN='\033[0;32m'
YEL='\033[1;33m'
NC='\033[0m'

echo -e "\${RED}╔════════════════════════════════════════════╗\${NC}"
echo -e "\${RED}║     Runix Uninstaller                      ║\${NC}"
echo -e "\${RED}╚════════════════════════════════════════════╝\${NC}"
echo

echo -e "\${YEL}This will remove:${NC}"
echo -e "  • $INSTALL_DIR"
echo -e "  • $BIN_DIR/runix"
echo -e "  • $BIN_DIR/run"
echo -e "  • $CONFIG_DIR"
echo

echo -ne "\${RED}Are you sure? (y/n): \${NC}"
read -r confirm

if [[ "\$confirm" =~ ^[yY]$ ]]; then
    echo -e "\${YEL}Uninstalling Runix...\${NC}"
    
    # Remove files
    rm -rf "$INSTALL_DIR"
    rm -f "$BIN_DIR/runix" "$BIN_DIR/run"
    rm -rf "$CONFIG_DIR"
    
    # Remove from shell configs
    for rc in ~/.bashrc ~/.zshrc ~/.bash_profile ~/.config/fish/config.fish; do
        if [[ -f "\$rc" ]]; then
            # Remove the Runix comment and any PATH export lines that reference the BIN_DIR
            sed -i.bak '/# Runix/d' "\$rc" 2>/dev/null || true
            sed -i.bak "\|$BIN_DIR|d" "\$rc" 2>/dev/null || true
            rm -f "\${rc}.bak"
        fi
    done
    
    echo -e "\${GRN}✓ Runix has been uninstalled\${NC}"
    echo -e "\${YEL}You may need to restart your shell\${NC}"
    
    # Self-delete
    rm -f "\$0"
else
    echo -e "\${YEL}Uninstall cancelled\${NC}"
fi
EOF
    
    chmod +x "$uninstall_script"
    echo -e "${GRN}✓ Uninstaller created: $uninstall_script${NC}"
}

# Run initial setup
run_initial_setup() {
    echo -e "${BLU}🎬 Running initial setup...${NC}"
    echo
    
    if command -v runix >/dev/null 2>&1; then
        runix help || true
    elif [[ -x "$BIN_DIR/runix" ]]; then
        "$BIN_DIR/runix" help || true
    else
        echo -e "${YEL}⚠️  Please restart your shell or run:${NC}"
        echo -e "    ${CYAN}source ~/.bashrc${NC}  # or your shell config"
        echo -e "    ${CYAN}runix help${NC}"
    fi
}

# Show completion message
show_completion() {
    echo
    echo -e "${GRN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GRN}║                                                            ║${NC}"
    echo -e "${GRN}║          ✨ Installation Complete! ✨                      ║${NC}"
    echo -e "${GRN}║                                                            ║${NC}"
    echo -e "${GRN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${CYAN}📍 Installation Location: ${YEL}$INSTALL_DIR${NC}"
    echo -e "${CYAN}🔗 Binary Location: ${YEL}$BIN_DIR/runix${NC}"
    echo -e "${CYAN}⚙️  Config Location: ${YEL}$CONFIG_DIR${NC}"
    echo
    echo -e "${BOLD}Quick Start:${NC}"
    echo -e "  ${GRN}runix help${NC}           - Show all commands"
    echo -e "  ${GRN}runix info${NC}           - Show configuration"
    echo -e "  ${GRN}runix test.py${NC}        - Run a Python file"
    echo -e "  ${GRN}run test.c${NC}           - Short alias"
    echo
    echo -e "${BOLD}Next Steps:${NC}"
    echo -e "  1. Restart your shell or run: ${CYAN}source ~/.bashrc${NC}"
    echo -e "  2. Run: ${CYAN}runix help${NC}"
    echo -e "  3. Try running a file: ${CYAN}runix yourfile.py${NC}"
    echo
    echo -e "${BOLD}Uninstall:${NC}"
    echo -e "  ${YEL}bash $INSTALL_DIR/uninstall.sh${NC}"
    echo
    echo -e "${BOLD}Documentation:${NC}"
    echo -e "  ${BLU}$GITHUB_REPO${NC}"
    echo
    echo -e "${MAG}Thank you for installing Runix! 🚀${NC}"
    echo
}

# Main installation flow
main() {
    show_banner
    
    # Detect system
    detect_os
    detect_arch
    
    # Show system info
    show_system_info
    
    # Pre-installation checks
    check_root
    check_internet
    check_dependencies
    
    # Choose installation type
    choose_install_type
    
    # Setup directories
    setup_directories
    
    # Confirm installation
    echo -e "${YEL}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YEL}║  Ready to install Runix                                    ║${NC}"
    echo -e "${YEL}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo -ne "${BLU}Continue with installation? (y/n): ${NC}"
    read -r confirm
    
    if [[ ! "$confirm" =~ ^[yY]$ ]]; then
        echo -e "${YEL}Installation cancelled${NC}"
        exit 0
    fi
    
    echo
    
    # Download and install
    download_runix
    install_runix
    
    # Configuration
    setup_shell
    os_specific_setup
    
    # Create uninstaller
    create_uninstaller
    
    # Initial setup
    echo
    run_initial_setup
    
    # Show completion
    show_completion
}

# Handle errors
trap 'echo -e "\n${RED}❌ Installation failed${NC}"; exit 1' ERR

# Run main
main "$@"
