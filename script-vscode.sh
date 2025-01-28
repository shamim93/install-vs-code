#!/bin/bash

# Function to install VS Code for Debian-based systems (Ubuntu, etc.)
vscodeDebian() {
    echo "Detected a Debian-based system (e.g., Ubuntu)..."
    echo "Updating package lists and installing prerequisites..."
    sudo apt update -y && sudo apt install -y wget gpg apt-transport-https

    echo "Importing Microsoft GPG key..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft.gpg > /dev/null

    echo "Adding VS Code repository..."
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

    echo "Updating package lists after adding VS Code repository..."
    sudo apt update -y

    echo "Installing Visual Studio Code..."
    sudo apt install -y code
}

# Function to install VS Code for Fedora-based systems (Fedora, RHEL, CentOS)
vscodeFedora() {
    echo "Detected a Fedora-based system (e.g., Fedora, RHEL, CentOS)..."
    echo "Importing Microsoft GPG key..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

    echo "Adding VS Code repository..."
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

    echo "Installing Visual Studio Code..."
    sudo dnf install -y code || sudo yum install -y code
}

# Detect the Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        ubuntu|debian)
            vscodeDebian
            ;;
        fedora|rhel|centos)
            vscodeFedora
            ;;
        *)
            echo "Unsupported Linux distribution: $ID"
            exit 1
            ;;
    esac
elif [ -f /etc/centos-release ]; then
    # If it's CentOS, manually set the ID
    ID="centos"
    install_vscode_fedora
elif [ -f /etc/redhat-release ]; then
    # If it's RHEL-based (e.g., RedHat or CentOS)
    ID="rhel"
    install_vscode_fedora
else
    echo "Cannot detect the Linux distribution. /etc/os-release, /etc/centos-release, and /etc/redhat-release not found."
    exit 1
fi

# Verify installation
if command -v code >/dev/null 2>&1; then
    echo "Visual Studio Code successfully installed! 🎉"
else
    echo "Something went wrong. VS Code was not installed."
fi
