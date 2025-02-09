# Conky Setup Script

This repository contains an automated installation script to configure Conky, a system monitoring tool. The script performs the following tasks:

- **Installs the necessary dependencies:**  
  Ensures that Conky, curl, net-tools, lsof, xdg-utils, and rkhunter are installed.
- **Configures permissions and sudoers:**  
  Adjusts the permissions of `/var/log/rkhunter.log` and adds the user to the `adm` group for proper rkhunter functionality. It also sets up a sudoers file so that certain commands run without requiring a password.
- **Copies a custom Conky configuration:**  
  Generates the configuration file at `~/.config/conky/conky.conf` with predefined parameters (such as position, colors, update intervals, and more).
- **Creates a systemd service:**  
  Sets up and enables a service to ensure that Conky automatically starts when the system boots.

## Features

- **Automated Installation:**  
  The script updates the system, installs the required packages, and configures the necessary permissions.
- **Auto-start with systemd:**  
  Conky will automatically launch at every system boot.
- **Easy Customization:**  
  The Conky configuration is stored in `~/.config/conky/conky.conf`, allowing you to edit it to your liking.

## Requirements

- A Debian-based operating system (e.g., Ubuntu, Linux Mint).
- Sudo privileges.

## Installation and Usage

1. **Clone the repository:**

   Open a terminal and run:
   ```bash
   git clone https://github.com/jose-litium/conky-setup.git
   cd conky-setup
