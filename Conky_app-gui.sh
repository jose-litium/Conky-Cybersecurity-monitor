#!/usr/bin/env bash

# Conky Cybersecurity Monitor – Full App (Improved Version)
#
# Este script instala, configura y gestiona Conky junto con herramientas de seguridad
# (como RKHunter) utilizando una interfaz gráfica basada en dialog.
# También crea un lanzador de escritorio para iniciar la aplicación sin una terminal.
#
# Autor: jose-litium 2025
# GitHub: https://github.com/jose-litium
# LinkedIn: https://www.linkedin.com/in/josemmanueldiaz/
# Fecha: 2025-02-17 (Modificado: 2025-05-07)

########################################
# Global Configuration
########################################

LOGFILE="/tmp/conky_gui.log"
INSTALL_DIR="$HOME/.local/conky_app"
mkdir -p "$INSTALL_DIR"

# Define colors for terminal output (for logs)
BLUE='\033[1;34m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
MAGENTA='\033[1;35m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
RED='\033[1;31m'
NC='\033[0m'

########################################
# Utility functions (with dialog)
########################################

# Check if a command is installed
function is_command_installed() {
    command -v "$1" &>/dev/null
}

# Confirmation dialog
function dconfirm() {
    dialog --clear --yesno "$1" 7 60
    return $?
}

# Message dialog
function dmsg() {
    dialog --clear --msgbox "$1" 10 60
}

# Menu dialog (returns the chosen option)
function dmenu() {
    local title="$1"
    shift
    local options=("$@")
    local choice
    choice=$(dialog --clear --backtitle "Conky Cybersecurity Monitor" \
        --title "$title" \
        --menu "Choose an option:" 24 70 17 "${options[@]}" 2>&1 >/dev/tty)
    echo "$choice"
}

########################################
# Sudoers Configuration
########################################

function setup_sudoers() {
    echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/netstat, /usr/bin/lsof, /usr/bin/grep, /usr/bin/cat, /usr/bin/sensors, /usr/bin/journalctl, /usr/bin/curl, /usr/bin/hostname -I, /usr/bin/rkhunter" | sudo tee /etc/sudoers.d/conky > /dev/null
    sudo chmod 0440 /etc/sudoers.d/conky
    log "Sudoers updated for user $USER."
}

########################################
# Logging Functions
########################################

function log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

function clear_log_file() {
    > "$LOGFILE"
}

function run_cmd() {
    log "Running: $*"
    "$@" >> "$LOGFILE" 2>&1
}

########################################
# Internal Checks
########################################

function check_user_systemd() {
    if ! systemctl --user 2>/dev/null; then
        dmsg "User-level systemd is not available.\nPlease use a version of Ubuntu/Debian with a desktop environment (18.04+)."
        exit 1
    fi
}

function check_install() {
    local pkg="$1"
    if dpkg -l | grep -qw "$pkg"; then
        log "$pkg is already installed."
    else
        log "$pkg is not installed."
        if dconfirm "Do you want to install $pkg?"; then
            sudo apt update
            sudo apt install -y "$pkg"
        else
            dmsg "Skipped installing $pkg. This may affect functionality."
        fi
    fi
}

function configure_sensors() {
    echo -e "${BLUE}Configuring hardware sensors (lm-sensors)...${NC}"
    if command -v sensors &>/dev/null; then
            if dconfirm "Do you want to run sensors-detect to automatically configure your sensors?"; then
                echo -e "${BLUE}Running sensors-detect...${NC}"
                yes | sudo sensors-detect > /dev/null 2>&1
                dmsg "Sensors configuration completed."
            else
                dmsg "Skipped configuration with sensors-detect."
            fi
    else
        dmsg "lm-sensors is not installed. Skipping sensor configuration."
    fi
}

function create_rkhunter_scan_script() {
    local SCRIPT="$INSTALL_DIR/rkhunter_scan.sh"
    cat <<'EOF' > "$SCRIPT"
#!/usr/bin/env bash

sudo rkhunter --update > /dev/null 2>&1 && \
sudo rkhunter --propupd > /dev/null 2>&1 && \
sudo rkhunter --check --sk > /tmp/rkhunter_result.txt 2>/dev/null && \
grep -i "warning" /tmp/rkhunter_result.txt > /tmp/rkhunter_warnings.txt
EOF
    chmod +x "$SCRIPT"
    log "RKHunter scan script created at $SCRIPT."
}

function create_temp_monitor_script() {
    local SCRIPT="$INSTALL_DIR/temp_monitor.sh"
    cat <<'EOF' > "$SCRIPT"
#!/usr/bin/env bash

while true; do
    temp=$(sensors | grep -Eo '\+[0-9]+(\.[0-9]+)?°C' | head -n1)
    temp_val=$(echo "$temp" | sed 's/[+°C]//g')
    if [ -n "$temp_val" ] && awk "BEGIN {exit !($temp_val > 90)}"; then
        echo "N/A" > /tmp/cpu_temp.txt
    else
        echo "${temp:-N/A}" > /tmp/cpu_temp.txt
    fi
    sleep 10
done
EOF
    chmod +x "$SCRIPT"
    log "Temperature monitor script created at $SCRIPT."
}

function install_temp_monitor_service() {
    mkdir -p ~/.config/systemd/user
    cat <<EOL > ~/.config/systemd/user/temp_monitor.service
[Unit]
Description=CPU Temperature Monitor for Conky

[Service]
Type=simple
ExecStart=/usr/bin/env bash "$INSTALL_DIR/temp_monitor.sh"
Restart=always

[Install]
WantedBy=default.target
EOL

    systemctl --user daemon-reload
    systemctl --user enable temp_monitor.service
    systemctl --user start temp_monitor.service
    log "Temperature monitor service installed and started."
}

function install_rkhunter_service() {
    echo -e "${BLUE}Installing automatic RKHunter scan service...${NC}"
    sudo tee /etc/systemd/system/rkhunter-auto.service > /dev/null <<EOL
[Unit]
Description=RKHunter Automatic Scan
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'rkhunter --update > /dev/null 2>&1 && rkhunter --propupd > /dev/null 2>&1 && rkhunter --check --sk > /tmp/rkhunter_result.txt 2>/dev/null && grep -i "warning" /tmp/rkhunter_warnings.txt > /tmp/rkhunter_warnings.txt'
RemainAfterExit=yes
EOL

    sudo tee /etc/systemd/system/rkhunter-auto.timer > /dev/null <<EOL
[Unit]
Description=Timer for RKHunter automatic scans

[Timer]
OnBootSec=5min
OnUnitActiveSec=10min

[Install]
WantedBy=timers.target
EOL

    sudo systemctl daemon-reload
    sudo systemctl enable rkhunter-auto.timer
    sudo systemctl start rkhunter-auto.timer
    log "RKHunter service and timer installed."
}

function remove_rkhunter_service() {
    echo -e "${RED}Removing automatic RKHunter scan service and timer...${NC}"
    sudo systemctl disable rkhunter-auto.timer
    sudo systemctl stop rkhunter-auto.timer
    sudo rm -f /etc/systemd/system/rkhunter-auto.timer
    sudo systemctl disable rkhunter-auto.service
    sudo rm -f /etc/systemd/system/rkhunter-auto.service
    sudo systemctl daemon-reload
    log "RKHunter service and timer removed."
}

########################################
# Functions: Delete Logs and Temporary Files
########################################

function delete_temporaries() {
    rm -f /tmp/rkhunter_result.txt /tmp/rkhunter_warnings.txt /tmp/cpu_temp.txt
    dmsg "Temporary files deleted."
    log "Temporary files deleted."
}

function clear_logs() {
    clear_log_file
    dmsg "Log file cleared."
    log "Log file cleared."
}

function view_logs() {
    if [ -f "$LOGFILE" ]; then
        dialog --textbox "$LOGFILE" 20 70
    else
        dmsg "Log file not found."
    fi
}

function view_rkhunter_warnings() {
    local WARN_LOG="/tmp/rkhunter_warnings.txt"
    if [ -f "$WARN_LOG" ]; then
        dialog --textbox "$WARN_LOG" 20 70
    else
        dmsg "No RKHunter warnings log found."
    fi
}

########################################
# Function: Install Pentesting Tools
########################################

function install_pentest_tools() {
    if dconfirm "Install pentesting tools? (Already-installed tools will be skipped)"; then
        local TOOLS=("nmap" "sqlmap" "aircrack-ng" "hydra" "john" "metasploit-framework" "wireshark")
        for tool in "${TOOLS[@]}"; do
            check_install "$tool"
        done
        dmsg "Pentesting tools installation complete."
        log "Pentesting tools installation complete."
    else
        dmsg "Pentesting tools installation canceled."
    fi
}

########################################
# Function: Clean /var/log
########################################

function clean_var_log() {
    if dconfirm "Clean /var/log? This will vacuum journal logs to 1 day and truncate log files."; then
        sudo journalctl --vacuum-time=1d
        sudo find /var/log -type f -exec truncate -s 0 {} \;
        dmsg "/var/log system logs cleaned."
        log "/var/log system logs cleaned."
    else
        dmsg "Cleaning /var/log canceled."
    fi
}

########################################
# Function: Create Desktop Launcher
########################################

function create_launcher() {
    SCRIPT_PATH="$(readlink -f "$0")"
    DESKTOP_FILE="$HOME/.local/share/applications/conky-cybersecurity-monitor.desktop"
    mkdir -p "$HOME/.local/share/applications"
    cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=Conky Cybersecurity Monitor
Comment=Manage Conky Cybersecurity Monitor
Exec=$SCRIPT_PATH
Icon=
Terminal=false
Type=Application
Categories=Utility;
EOF
    dmsg "Desktop launcher created at $DESKTOP_FILE."
    log "Desktop launcher created at $DESKTOP_FILE."
    update-desktop-database "$HOME/.local/share/applications"
}

########################################
# Dependency Check Function (CORREGIDA)
########################################
function check_dependencies() {
    declare -A required_commands=(
        ["dialog"]="dialog"
        ["conky"]="conky"
        ["curl"]="curl"
        ["netstat"]="net-tools"
        ["lsof"]="lsof"
        ["xdg-open"]="xdg-utils"
        ["rkhunter"]="rkhunter"
        ["sensors"]="lm-sensors"
        ["nmap"]="nmap"
        ["upower"]="upower"
    )
    
    local missing_dependencies=()
    
    for cmd in "${!required_commands[@]}"; do
        if ! is_command_installed "$cmd"; then
            missing_dependencies+=("${required_commands[$cmd]}")
        fi
    done

    if [ ${#missing_dependencies[@]} -gt 0 ]; then
        echo -e "${RED}Faltan las siguientes dependencias:${NC}"
        for dep in "${missing_dependencies[@]}"; do
            echo "- $dep"
        done
        echo -e "${YELLOW}Por favor, instala las dependencias que faltan usando el gestor de paquetes de tu sistema.${NC}"

        if is_command_installed "apt"; then
            echo "Ejemplo para sistemas Debian/Ubuntu: sudo apt install ${missing_dependencies[*]}"
        elif is_command_installed "dnf"; then
            echo "Ejemplo para sistemas Fedora: sudo dnf install ${missing_dependencies[*]}"
        elif is_command_installed "yum"; then
            echo "Ejemplo para sistemas RHEL/CentOS: sudo yum install ${missing_dependencies[*]}"
        elif is_command_installed "pacman"; then
            echo "Ejemplo para sistemas Arch: sudo pacman -S ${missing_dependencies[*]}"
        else
            echo "No se detectó un gestor de paquetes común. Por favor, instala manualmente."
        fi
        
        exit 1
    fi
}

########################################
# Main Action Functions
########################################

function install_conky() {
    if ! dconfirm "Proceed with Conky installation and configuration?"; then
        dmsg "Installation canceled by user."
        return
    fi
    clear_log_file
    log "Starting Conky installation..."
    check_user_systemd
    echo -e "${BLUE}Updating package lists...${NC}"
    sudo apt update

    local APPS=("conky-all" "curl" "net-tools" "lsof" "xdg-utils" "rkhunter" "lm-sensors" "nmap" "upower")
    for pkg in "${APPS[@]}"; do
        check_install "$pkg"
    done

    configure_sensors
    create_rkhunter_scan_script

    echo -e "${BLUE}Adjusting permissions for RKHunter...${NC}"
    sudo chmod +r /var/log/rkhunter.log
    sudo usermod -aG adm "$(whoami)"

    echo -e "${BLUE}Configuring sudoers for Conky commands...${NC}"
    setup_sudoers

    mkdir -p ~/.config/conky
    local USERNAME="$USER"
    echo -e "${BLUE}Creating Conky configuration...${NC}"
    cat <<EOL > ~/.config/conky/conky.conf
conky.config = {
    alignment = 'top_right',
    background = false,
    double_buffer = true,
    update_interval = 1,
    own_window = true,
    own_window_type = 'desktop',
    own_window_argb_visual = true,
    own_window_argb_value = 140,
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
    gap_x = 15,
    gap_y = 50,
    minimum_width = 300,  -- Reduced width so Conky doesn't become too wide
    minimum_height = 750,
    draw_shades = false,
    draw_borders = false,
    use_xft = true,
    default_color = 'white',
    default_outline_color = 'blue',
    override_utf8_locale = true,
};

conky.text = [[
\${exec /home/${USERNAME}/.local/conky_app/rkhunter_scan.sh > /dev/null 2>&1}
\${color yellow}\${time %H:%M:%S}      Vietnam (GMT+7)
\${color cyan}\${execi 10 TZ='Europe/Madrid' date '+%H:%M:%S'}      Madrid (GMT+1)
\${color green}\${execi 10 TZ='Australia/Sydney' date '+%H:%M:%S'}      Sydney (GMT+10)
\${color magenta}\${execi 10 TZ='America/New_York' date '+%H:%M:%S'}      New York (GMT-5)

\${color magenta}------ Hardware Indicators ------
\${color white}CPU: \${if_match \${cpu cpu0} > 80}\${color red}\${cpu cpu0}%\${else}\${color green}\${cpu cpu0}%\${endif} \${cpubar cpu0 10,}
\${color white}RAM: \${if_match \${memperc} > 40}\${color red}\${memperc}%\${else}\${color green}\${memperc}%\${endif} \${membar 10}
\${color white}Main HDD: \${if_match \${fs_used_perc /} > 60}\${color red}\${fs_used_perc /}%\${else}\${color green}\${fs_used_perc /}%\${endif} \${fs_bar /}
\${color white}CPU Temp: \${color red}\${execi 10 cat /tmp/cpu_temp.txt || echo "N/A"}
\${color white}Uptime: \${color green}\${uptime}

\${color magenta}------ Network Information ------
\${color white}Local IP: \${color cyan}\${execi 10 hostname -I | cut -d' ' -f1}
\${color white}Public IP: \${color cyan}\${execi 600 curl -s ifconfig.me}
\${color white}VPN: \${execi 30 bash -c 'if ip link show | grep -Eiq "^(tun|tap|ppp)"; then echo "\${color yellow}VPN active\${color white}"; else echo "\${color yellow}VPN inactive\${color white}"; fi'}
\${color white}SSH Status: \${color yellow}\${execi 30 systemctl is-active ssh}
\${color white}Established Connections: \${color red}\${execi 10 netstat -an | grep ESTABLISHED | wc -l}
\${color white}Open Ports: \${color red}\${execi 10 netstat -tuln | grep LISTEN | wc -l}

\${color magenta}------ Connected Users ------
\${color white}Users: \${color cyan}\${execi 30 who | awk '{print \$1}' | sort | uniq | xargs}

\${color magenta}------ Security Events ------
\${color white}Recent Events: \${color red}\${execi 30 journalctl -n 5 -p 3 -u ssh.service --no-pager | tail -n 5}

\${color magenta}------ Rootkit Alerts ------
\${color white}Alerts: \${execi 600 bash -c 'if [ -f /tmp/rkhunter_warnings_prev.txt ]; then if cmp -s /tmp/rkhunter_warnings.txt /tmp/rkhunter_warnings_prev.txt; then echo "No new alerts"; else echo "New alerts detected - check /tmp/rkhunter_warnings.txt"; cp /tmp/rkhunter_warnings.txt /tmp/rkhunter_warnings_prev.txt; fi; else if [ -s /tmp/rkhunter_warnings.txt ]; then echo "Alerts detected - check /tmp/rkhunter_warnings.txt"; cp /tmp/rkhunter_warnings.txt /tmp/rkhunter_warnings_prev.txt; else echo "No alerts"; fi; fi'}
\${color magenta}------ Top 5 Processes ------
\${color white}\${execi 5 ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6 | tail -n 5}
]];
EOL

    mkdir -p ~/.config/systemd/user
    cat <<EOL > ~/.config/systemd/user/conky.service
[Unit]
Description=Conky (User Level)
After=default.target

[Service]
Type=simple
ExecStart=/usr/bin/conky -b -c "/home/$USER/.config/conky/conky.conf"
Restart=on-failure

[Install]
WantedBy=default.target
EOL

    systemctl --user daemon-reload
    systemctl --user enable conky.service
    systemctl --user start conky.service

    dmsg "Conky installation completed and service started."
    log "Conky installed and service started."
    create_temp_monitor_script
    install_temp_monitor_service
    install_rkhunter_service
}

function uninstall_conky() {
    if dconfirm "Are you sure you want to completely remove Conky and all its processes?"; then
        echo -e "${RED}Stopping Conky service and related processes...${NC}"
        if [ -f ~/.config/systemd/user/conky.service ]; then
            systemctl --user stop conky.service
            systemctl --user disable conky.service
            rm -f ~/.config/systemd/user/conky.service
            systemctl --user daemon-reload
        fi
        if [ -f ~/.config/systemd/user/temp_monitor.service ]; then
            systemctl --user stop temp_monitor.service
            systemctl --user disable temp_monitor.service
            rm -f ~/.config/systemd/user/temp_monitor.service
            systemctl --user daemon-reload
        fi
        pkill -f conky
        sleep 1
        echo -e "${RED}Removing Conky configuration...${NC}"
        rm -rf ~/.config/conky
        echo -e "${GREEN}Removing conky and conky-all packages...${NC}"
        sudo apt remove --purge -y conky conky-all
        dmsg "Conky uninstallation completed."
    else
        dmsg "Uninstallation canceled."
    fi
}

function start_conky() {
    echo -e "${GREEN}Starting Conky service (user-level)...${NC}"
    if [ -f ~/.config/systemd/user/conky.service ]; then
        systemctl --user start conky.service
        systemctl --user status conky.service --no-pager
        dmsg "Conky service started."
    else
        dmsg "No user-level conky.service found. Please install Conky first."
    fi
}

function stop_conky() {
    echo -e "${GREEN}Stopping Conky service (user-level)...${NC}"
    if [ -f ~/.config/systemd/user/conky.service ]; then
        systemctl --user stop conky.service
        systemctl --user status conky.service --no-pager
        dmsg "Conky service stopped."
    else
        dmsg "No user-level conky.service found. Please install Conky first."
    fi
}

function restart_conky() {
    echo -e "${GREEN}Restarting Conky service (user-level)...${NC}"
    if [ -f ~/.config/systemd/user/conky.service ]; then
        systemctl --user restart conky.service
        systemctl --user status conky.service --no-pager
        dmsg "Conky service restarted."
    else
        dmsg "No user-level conky.service found. Please install Conky first."
    fi
}

function check_rkhunter() {
    echo -e "${BLUE}Running RKHunter scan...${NC}"
    local WARN_LOG="/tmp/rkhunter_warnings.txt"
    sudo rkhunter --update > /dev/null 2>&1
    sudo rkhunter --propupd > /dev/null 2>&1
    sudo rkhunter --check --sk > /tmp/rkhunter_result.txt 2>/dev/null
    grep -i "warning" /tmp/rkhunter_result.txt > "$WARN_LOG"
    if [ -s "$WARN_LOG" ]; then
        local count
        count=$(wc -l < "$WARN_LOG")
        dmsg "You have ${count} alert(s).\nCheck warnings with: cat $WARN_LOG"
    else
        dmsg "No alerts detected."
        rm -f "$WARN_LOG"
    fi
}

function restore_system() {
    if dconfirm "Restore essential system packages?"; then
        echo -e "${BLUE}Restoring essential system packages...${NC}"
        sudo apt update
        local ESSENTIAL_PACKAGES=("ubuntu-desktop" "gdm3" "nautilus" "gvfs" "gvfs-backends" "gvfs-daemons" "gvfs-common" "ubuntu-standard" "ubuntu-minimal" "dbus-x11" "network-manager")
        local note
        for pkg in "${ESSENTIAL_PACKAGES[@]}"; do
            case "$pkg" in
                "ubuntu-desktop")
                    note="(Installs the default Ubuntu desktop environment)";;
                "gdm3")
                    note="(Installs the GNOME Display Manager)";;
                "nautilus")
                    note="(Installs the GNOME file manager)";;
                "gvfs")
                    note="(Installs the GNOME Virtual File System)";;
                "gvfs-backends")
                    note="(Provides backends for GVFS)";;
                "gvfs-daemons")
                    note="(Installs daemons for GVFS)";;
                "gvfs-common")
                    note="(Common files for GVFS)";;
                "ubuntu-standard")
                    note="(Standard packages for Ubuntu)";;
                "ubuntu-minimal")
                    note="(Minimum required packages for Ubuntu)";;
                "dbus-x11")
                    note="(X11 support for DBus)";;
                "network-manager")
                    note="(Manages network connections)";;
                *)
                    note="(No additional information)";;
            esac
            if dconfirm "Reinstall $pkg $note?"; then
                sudo apt install -y "$pkg"
            else
                echo -e "${YELLOW}Skipping reinstallation of $pkg.${NC}"
            fi
        done
        if dconfirm "Run 'sudo apt --fix-broken install -y'? (This will fix broken dependencies)"; then
            sudo apt --fix-broken install -y
        else
            echo -e "${YELLOW}Skipping broken install fixes.${NC}"
        fi
        if ! dpkg -l | grep -qw google-chrome-stable; then
            if dconfirm "Google Chrome is not installed. Do you want to install it?"; then
                wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/google-chrome-stable_current_amd64.deb
                sudo dpkg -i /tmp/google-chrome-stable_current_amd64.deb || sudo apt -f install -y
            else
                echo -e "${YELLOW}Skipping Google Chrome installation.${NC}"
            fi
        else
            if dconfirm "Google Chrome is already installed. Do you want to reinstall it?"; then
                sudo apt install --reinstall -y google-chrome-stable
            else
                echo -e "${YELLOW}Keeping the current Google Chrome installation.${NC}"
            fi
        fi
        dmsg "Restoration of essential packages completed."
    else
        dmsg "System restoration canceled."
    fi
}

########################################
# Main Menu (GUI with dialog)
########################################

# Perform initial dependency check
check_dependencies

# Welcome banner
dialog --clear --title "Welcome to Conky Cybersecurity Monitor" --msgbox "This application installs, configures, and manages Conky together with security tools like RKHunter and a temperature monitor. It also sets up a desktop launcher and offers options to view logs, remove temporary files, install pentesting tools, and clean system logs.\n\nDeveloped by jose-litium 2025\nGitHub: https://github.com/jose-litium\nLinkedIn: https://www.linkedin.com/in/josemmanueldiaz/" 15 70

while true; do
    choice=$(dialog --clear --backtitle "Conky Cybersecurity Monitor" \
        --title "Main Menu" \
        --menu "Choose an option:" 28 70 17 \
        1 "Install Conky" \
        2 "Uninstall Conky" \
        3 "Start Conky" \
        4 "Stop Conky" \
        5 "Restart Conky" \
        6 "Run RKHunter Scan (Manual)" \
        7 "Restore Essential System Packages" \
        8 "Install Automatic RKHunter Service" \
        9 "Remove Automatic RKHunter Service" \
        10 "Create Desktop Launcher" \
        11 "View Application Logs" \
        12 "View RKHunter Warnings" \
        13 "Delete Temporary Files" \
        14 "Clear Logs" \
        15 "Install Pentesting Tools" \
        16 "Clean /var/log" \
        17 "Exit" 2>&1 >/dev/tty)
    
    case "$choice" in
        1) install_conky ;;
        2) uninstall_conky ;;
        3) start_conky ;;
        4) stop_conky ;;
        5) restart_conky ;;
        6) check_rkhunter ;;
        7) restore_system ;;
        8) install_rkhunter_service ;;
        9) remove_rkhunter_service ;;
        10) create_launcher ;;
        11) view_logs ;;
        12) view_rkhunter_warnings ;;
        13) delete_temporaries ;;
        14) clear_logs ;;
        15) install_pentest_tools ;;
        16) clean_var_log ;;
        17)
            dialog --clear --msgbox "Goodbye, and thank you for using the application!\n\njose-litium 2025\nGitHub: https://github.com/jose-litium\nLinkedIn: https://www.linkedin.com/in/josemmanueldiaz/" 10 70
            clear
            exit 0
            ;;
        *) dialog --clear --msgbox "Invalid option. Please try again." 7 60 ;;
    esac
done
