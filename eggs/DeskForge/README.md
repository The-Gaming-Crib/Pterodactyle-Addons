# DeskForge

Linux desktops for Pterodactyl, reachable only through real remote-desktop protocols. There is no web page or browser access. Pick a distro and desktop environment (XFCE, KDE Plasma, MATE, LXQt) from the Docker image dropdown. Container based (no KVM, no emulation), ARM and x86.

## Connecting (Access variable)
| Access | Connect with | Notes |
|---|---|---|
| `rdp` | Windows Remote Desktop, Remmina, any RDP client | user = RDP username, password = Desktop password (FreeRDP shadow server) |
| `vnc` | TigerVNC, RealVNC, Remmina | password only (8 chars max), unencrypted: prefer the SSH tunnel |
| `ssh` | any SSH client | key login only; X11 forwarding, SFTP, and tunnel to the desktop |
| `rdp+ssh`, `rdp+vnc`, `vnc+ssh`, `rdp+vnc+ssh`, `all` | combinations | first protocol uses the primary port, then +1, +2 (order rdp, vnc, ssh): create those extra allocations |

Safest setup: `Access = ssh`, then `ssh -p PORT -L 5901:localhost:5901 container@HOST` and connect your VNC client to `localhost:5901`. Only the SSH port is exposed, and only your key gets in. Restrict the port to your own IP in the node firewall / Oracle security list.

## Layout
- `egg-deskforge.json` import into a nest
- `images/<distro>/Dockerfile` one folder per distro; `images/common/` shared startup scripts
- `.github/workflows/build-deskforge.yml` builds every image to `ghcr.io/the-gaming-crib/deskforge:<tag>`

## Setup
1. Actions > build-deskforge > Run workflow (failed builds don't stop the rest).
2. Packages > deskforge > make Public so Wings can pull.
3. Import the egg, remove dropdown entries whose build failed.
4. Server: 1+ ports, 2 GB+ RAM (KDE 3 GB+).

Status: untested. RDP depends on the distro shipping a FreeRDP shadow server; images without it print a warning and still serve VNC/SSH.
