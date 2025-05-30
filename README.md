# Conky Cybersecurity Monitor

**Automate the installation, configuration, and management of Conky as a cybersecurity dashboard on Linux, integrating security tools (like RKHunter), hardware sensors, and pentesting utilities—all through a graphical dialog-based interface.**

- **Author:** jose-litium (2025)
- **GitHub:** [https://github.com/jose-litium](https://github.com/jose-litium)
- **LinkedIn:** [https://www.linkedin.com/in/josemmanueldiaz/](https://www.linkedin.com/in/josemmanueldiaz/)
- **Last update:** 2025-05-07

---

## Description

This script sets up and manages **Conky** as a visual security and hardware monitoring panel, including:
- System diagnostics (CPU, RAM, disk, temperature, processes, logs, network).
- Automated/manual rootkit scanning with **RKHunter**.
- Service management via **systemd** (user/system).
- One-click installation of popular pentesting tools (nmap, sqlmap, aircrack-ng, etc).
- Log cleaning, system package restoration, and desktop launcher creation.
- All actions via friendly dialog menus.

---

## Requirements

- **Distribution:** Ubuntu/Debian (18.04+ with systemd and desktop environment recommended).
- **Sudo privileges**.
- **apt** package manager (other package managers partially supported).
- **Minimum dependencies** (auto-checked by script):
  - `dialog`, `conky`, `curl`, `net-tools`, `lsof`, `xdg-utils`, `rkhunter`, `lm-sensors`, `nmap`, `upower`

The script checks for dependencies and provides install instructions if needed.

---

## Installation & Usage

1. **Download the script:**
   ```bash
   wget https://raw.githubusercontent.com/jose-litium/conky-cybersecurity-monitor/main/conky_cybersecurity_monitor.sh
   chmod +x conky_cybersecurity_monitor.sh
   ```

2. **Run the script:**
   ```bash
   ./conky_cybersecurity_monitor.sh
   ```
   > **Note:** Run as your normal user (NOT root). You’ll be asked for your sudo password to install dependencies and set up services.

3. **Follow the menu prompts:**
   - Install/uninstall Conky.
   - Start/stop/restart services.
   - Run rootkit scans.
   - Install pentesting tools.
   - Clean logs, restore system packages, create desktop launcher, and more.

---

## Main Features

- **Graphical main menu:** Navigate with `dialog` interface.
- **Automated install/config:** Conky, RKHunter, sensors, services, sudoers.
- **Desktop launcher:** Launch from the application menu, no terminal needed.
- **Log and temp file management.**
- **Critical system package restoration.**
- **One-click installation for top pentesting tools.**
- **System log cleaning for privacy.**

---

## Menu and Code Structure (Mermaid Diagram)

```mermaid
flowchart TD
    A[Start: Dependency Check & Welcome] --> B{Main Menu (dialog)}
    B --> C1[Install Conky]
    B --> C2[Uninstall Conky]
    B --> C3[Start Conky Service]
    B --> C4[Stop Conky Service]
    B --> C5[Restart Conky Service]
    B --> C6[Manual RKHunter Scan]
    B --> C7[Restore System Packages]
    B --> C8[Install RKHunter Service]
    B --> C9[Remove RKHunter Service]
    B --> C10[Create Desktop Launcher]
    B --> C11[View Logs]
    B --> C12[View RKHunter Warnings]
    B --> C13[Delete Temp Files]
    B --> C14[Clear Logs]
    B --> C15[Install Pentesting Tools]
    B --> C16[Clean /var/log]
    B --> C17[Exit]

    C1 --> D1[Configure Sensors, Create Services, Setup Sudoers, Generate Conky Config]
    C2 --> D2[Remove Services, Config, Packages]
    C3 --> D3[Start systemd/user service]
    C4 --> D4[Stop systemd/user service]
    C5 --> D5[Restart systemd/user service]
    C6 --> D6[Run RKHunter, Show Report]
    C7 --> D7[Restore Ubuntu/Debian Core Packages]
    C8 --> D8[Install systemd RKHunter Timer]
    C9 --> D9[Remove systemd RKHunter Timer]
    C10 --> D10[Generate .desktop Launcher]
    C11 --> D11[Display Log File in Dialog]
    C12 --> D12[Display RKHunter Warnings]
    C13 --> D13[Delete Files in /tmp]
    C14 --> D14[Clear Application Log]
    C15 --> D15[Install Security Tools]
    C16 --> D16[Vacuum and Truncate System Logs]
    C17 --> E[Goodbye Message & Exit]
```

---

## Main Script Functions

- `install_conky()`: Full setup (Conky, sensors, RKHunter, services, sudoers).
- `uninstall_conky()`: Complete removal of Conky and related services/config.
- `install_rkhunter_service()`: Enable automatic RKHunter scan as a systemd timer.
- `install_pentest_tools()`: Install tools: nmap, sqlmap, aircrack-ng, hydra, john, metasploit, wireshark.
- `clean_var_log()`: Clean and truncate system logs.
- `restore_system()`: Optionally restore packages like ubuntu-desktop, nautilus, etc.
- `create_launcher()`: Create a desktop application launcher.
- ...and many more for logs, diagnostics, and interactive menus.

---

## Customization

- **Conky config:** `~/.config/conky/conky.conf` (auto-generated, editable).
- **Helper scripts:** Copied to `~/.local/conky_app/`.

Edit `conky.conf` for panel layout, colors, or monitored data after setup.

---

## Uninstallation

Choose "Uninstall Conky" from the main menu, or run the script and select the option.

---

## Security

- **Minimal sudoers configuration:** Only for needed commands (/etc/sudoers.d/conky).
- **No dangerous commands run without confirmation.**
- **Logs:** `/tmp/conky_gui.log`, RKHunter warnings in `/tmp/rkhunter_warnings.txt`.

---

## Credits

Developed by jose-litium (2025).  
Questions or suggestions? Open an issue or pull request on the official repo!

---

## License

MIT — Use and modify freely, credit the author.

---

## Screenshots

*(Add screenshots here if desired)*

---

## Links

- [GitHub Repository](https://github.com/jose-litium)
- [Author on LinkedIn](https://www.linkedin.com/in/josemmanueldiaz/)

---

**Enjoy your automated Conky Cybersecurity Monitor!**
