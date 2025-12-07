# qBittorrent over VPN

A **Dockerized qBittorrent client** that routes all traffic through a VPN, ensuring privacy and security. This project provides an out-of-the-box solution for running qBittorrent with OpenVPN, including automatic port forwarding (if supported by your VPN provider) and a kill switch to prevent IP leaks.

---

## ✨ Features
- **qBittorrent WebUI**: Access and manage your torrents via a web interface.
- **OpenVPN Client**: All traffic is routed through a VPN for privacy.
- **Kill Switch**: Prevents IP leaks if the VPN connection drops.
- **Automatic Port Forwarding**: Uses `natpmpc` to request and maintain an open port (if supported by your VPN provider).
- **Lightweight**: Built on Debian Trixie slim for minimal resource usage.
- **Torrent list autosave**: Autosave the active torrents list
- **qBittorrent settings persistency**: provides a way to save qBittorrent settings between container runs

---

## 🚀 How to Test

### Prerequisites
- Docker and Docker Compose installed on your system.
- A VPN provider that supports OpenVPN and (optionally) port forwarding.

### Steps
1. Download the [`compose.yml`](compose.yml) file. Take a look at its contents to understand how to tune the container settings for you.
2. Run the following command to start the container:
   ```bash
   docker compose up
   ```
3. The container expects two volumes, edit `compose.yml` according to your setup:
   - `/home/qbittorrent/Downloads`: Where downloaded files will be stored.
   - `/root/vpn-config`: This folder must contain:
     - An `.ovpn` configuration file for your VPN.
     - A `.txt` file with your VPN credentials (username on the first line, password on the second).
4. After starting the container, an automated routine asks the VPN server to forward a port through `natpmpc` then the received port is shown in the container logs:
   ```bash
   docker logs <container_name>
   ```
5. Access the qBittorrent WebUI using the provided address. The default login credentials are:
   - **Username**: `admin`
   - **Password**: `adminadmin`
   **⚠️ Important:** Change the password after your first login.
6. The qBittorrent port should be up to date with the output of Docker logs. Check it from the "Settings" panel in the WebUI.

---

## 🛠️ Troubleshooting

### `natpmpc` Errors
`natpmpc` requires the VPN tunnel interface gateway to work. Due to routing table conflicts, the gateway cannot be automatically detected. If the heuristic fails, manually override it by setting the `VPN_GATEWAY` environment variable in your `compose.yml`:
```yaml
environment:
  VPN_GATEWAY: <your_vpn_gateway_ip>
```
This works only if you VPN provider allows port forwarding through natpmpc requests. If you want to disable this routine just define in your `compose.yml` this variable `DISABLE_NATPMPC`.  
**⚠️ Important:** You won't be able to seed your torrents!

### Firewall Configuration
The container enforces the following firewall rules by default:

| Rule                                      | Policy |
|-------------------------------------------|--------|
| Traffic through `tun0`                    | ALLOW  |
| UDP traffic to `<VPN_ADDRESS>` port `1194`| ALLOW  |
| Replies from `<VPN_ADDRESS>` port `1194`  | ALLOW  |
| Incoming TCP traffic to port `8080`       | ALLOW  |
| Replies from port `8080`                  | ALLOW  |
| DNS requests to `1.1.1.1` port `53`       | ALLOW  |
| Replies from `1.1.1.1` port `53`          | ALLOW  |
| All other traffic                         | DROP   |

**Note:** The qBittorrent WebUI can only be hosted on port `8080`.

---

## 🤝 Contributing
Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

---

## 📜 License
This project is licensed under the [Unlicense License](LICENSE).

---

## ⚠️ Legal Notice
Use Responsibly and Legally:  
This project is intended for legal and ethical use only. The use of torrents and peer-to-peer (P2P) networks is subject to the laws and regulations of your country. Downloading or sharing copyrighted material without permission is illegal in many jurisdictions and violates the terms of service of most VPN providers.  
  
You are solely responsible for ensuring that your use of this software complies with all applicable laws and regulations. The developers of this project do not condone or support the illegal distribution or downloading of copyrighted content.  
