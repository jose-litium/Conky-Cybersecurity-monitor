# Conky Cybersecurity Monitor  
**Automate the installation, configuration, and management of Conky as a cybersecurity dashboard on Linux**  

---

##  Overview  
Transform your Linux desktop into a real-time cybersecurity monitoring station with this comprehensive dialog-driven interface. The script integrates security tools, hardware sensors, and pentesting utilities into a sleek Conky dashboard.

---

##  Requirements  
| **Component**       | **Details**                                      |
|---------------------|--------------------------------------------------|
| **Distributions**   | Ubuntu/Debian (18.04+ recommended)              |
| **Privileges**      | Sudo access required                            |
| **Dependencies**    | `dialog`, `conky`, `curl`, `rkhunter`, `lm-sensors`, `nmap`, `upower` |

---

##  Installation  
```bash
wget https://raw.githubusercontent.com/jose-litium/conky-cybersecurity-monitor/main/conky_cybersecurity_monitor.sh
chmod +x conky_cybersecurity_monitor.sh
./conky_cybersecurity_monitor.sh
```

> **Note**: Run as regular user (not root). Sudo password required for setup.

---

##  Key Features  
- **Automated Dashboard Setup**: Conky + RKHunter + sensors  
- **Pentesting Toolkit**: One-click install:  
  ```nmap, sqlmap, aircrack-ng, hydra, john, metasploit, wireshark```  
- **System Monitoring**: CPU/RAM/disk/temp/network/logs  
- **Security Operations**:  
  - Rootkit scanning (manual/auto)  
  - Log cleaning & system restoration  
  - Desktop launcher creation  
- **Service Management**: systemd integration (user/system)  

---
## Looks of the final version

<img src="https://github.com/jose-litium/Conky-Cybersecurity-monitor/blob/main/1.png" alt="Final version look" style="width:10%; height:auto;" />

*Visual dialog interface with color-coded options*
---
## 🖥Interactive Menu

<img src="https://github.com/jose-litium/Conky-Cybersecurity-monitor/blob/main/2.png" alt="Interactive Menu" style="width:50%;" />

*Visual dialog interface with color-coded options*



---

## Configuration  
**Conky Config**: `~/.config/conky/conky.conf`  
**Helper Scripts**: `~/.local/conky_app/`  
**Customize**: Colors, layout, and monitored metrics via config file  

---

## Security Design  
- Minimal sudo permissions via `/etc/sudoers.d/conky`  
- All operations require explicit confirmation  
- Audit logs: `/tmp/conky_gui.log`  
- RKHunter warnings: `/tmp/rkhunter_warnings.txt`  

---

##  System Flow  
```mermaid
flowchart TD
    A[Start: Dependency Check] --> B{Main Menu}
    B --> C1[Install Conky Dashboard]
    B --> C2[Uninstall Conky]
    B --> C3[Service Controls]
    B --> C4[Security Scans]
    B --> C5[Pentest Tools]
    B --> C6[System Utilities]
    B --> C7[Exit]
    
    C1 --> D1[Install Packages\nConfigure Sensors\nGenerate Conky Config\nSetup Services]
    C3 --> D3[Start/Stop/Restart\nsystemd Services]
    C4 --> D4[Manual RKHunter Scan\nView Warnings]
    C5 --> D5[Install:\nnmap,sqlmap\naircrack-ng,etc]
    C6 --> D6[Clean Logs\nRestore Packages\nCreate Launcher\nTemp Cleanup]
```

---

##  Uninstallation  
Run script → Select **"Uninstall Conky"** → Complete removal of:  
- Config files  
- Services  
- Sudo permissions  
- Helper scripts  

---

##  Credits  
**Author**: jose-litium (2025)  
[![GitHub](https://img.shields.io/badge/GitHub-Repository-181717?logo=github)](https://github.com/jose-litium) 
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Profile-0A66C2?logo=linkedin)](https://www.linkedin.com/in/josemmanueldiaz/)  

**License**: MIT - Free to use and modify  

---

> **Enjoy your real-time security dashboard!**   
> Report issues or contribute on [GitHub](https://github.com/jose-litium)
