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

## Root inside the desktop

Open a terminal in the desktop and run `sudo -i` (or `sudo <command>`, or just `root`). You get a root shell in a private copy of the OS built with `proot`, so `apt`/`pacman`/`dnf`/`apk` installs work. The first use copies the OS into `~/.rootfs` (one time, takes a minute). Installed packages survive restarts. It is root only inside that sandbox and has no access to the host or other servers.

## Games (built into every image)

Every image includes Prism Launcher (Minecraft, imports CurseForge modpacks) with Java 17/21 and software-GL libraries, with a desktop shortcut. On Ubuntu ARM nodes, Steam runs through FEX-Emu (first launch downloads ~1-2 GB). Alpine is the exception (its musl libc cannot run the Prism AppImage). The official CurseForge app has no Linux build, so Prism is used for CurseForge packs. There is no GPU: graphics are software rendered, so light games only.

## Desktops

Ubuntu images use an Ubuntu-style XFCE (Yaru theme, Ubuntu wallpaper, dock on the left). `Ubuntu 24.04 - GNOME` is the real Ubuntu desktop (experimental, heavy without a GPU; GNOME 26.04 is Wayland-only so there is no 26.04 GNOME). Other distros use XFCE only.
