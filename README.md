# Conky Cybersecurity Monitor Setup Guide

## Key Features

# Automated Installation: The provided script updates your system, installs necessary packages, and handles all the configuration and permissions for you.
# Systemd Auto-Start: Conky starts automatically whenever you boot your system.
# Easy Customization: You can tweak the look, update intervals, and other settings in the Conky configuration file.

## What You'll Need

# A Debian-based operating system (e.g., Ubuntu, Linux Mint)
# Sudo privileges

# How to Install and Use

# Clone the Repository:
git clone https://github.com/jose-litium/Conky-Cybersecurity-monitor.git

# Navigate to the Directory:
cd Conky-Cybersecurity-monitor

# Make the Installation Script Executable:
chmod +x install_conky.sh

# Run the Installation Script:
./install_conky.sh
# The script will ask for your sudo password and then:
# - Update your system and install dependencies.
# - Set up permissions and create a sudoers file.
# - Copy the Conky configuration to ~/.config/conky/conky.conf.
# - Create and enable a systemd service to auto-start Conky.

# Changing Privileges and Customization

# Modifying File Permissions:
# The script handles file permissions for `/var/log/rkhunter.log` and sets up a sudoers file.
# You can manually edit these by editing the sudoers file:
# sudo nano /etc/sudoers.d/conky

# After making changes, ensure correct permissions:
# sudo chmod 0440 /etc/sudoers.d/conky

# Customizing the Conky Configuration:
# The Conky configuration file is located at `~/.config/conky/conky.conf`.
# Edit it to change position, colors, update intervals, and more:
# nano ~/.config/conky/conky.conf

# Save changes and restart the Conky service to apply (explained below).

# Managing the Systemd Service

# Check Service Status:
systemctl status conky.service

# Restart the Service:
sudo systemctl restart conky.service

# View Logs:
journalctl -u conky.service

# Troubleshooting

# Conky Doesn't Start:
# Check the service status using:
# systemctl status conky.service
# Look for error messages and ensure dependencies are installed.

# Permission Issues or Missing Dependencies:
# Manually install missing packages:
# sudo apt install conky curl net-tools lsof xdg-utils rkhunter
# Ensure your user is added to the adm group and that permissions on `/var/log/rkhunter.log` are correct.

# Contributions

# Feel free to contribute, report bugs, or make suggestions! If you find any issues or have ideas for improvements, fork the repository, make changes, and submit a pull request.
