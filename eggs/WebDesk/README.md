# WebDesk

Linux desktops in your browser as a Pterodactyl egg: pick a distro and desktop environment (XFCE, KDE Plasma, MATE, LXQt) from the Docker image dropdown. Container based (no KVM, no emulation), works on ARM and x86 nodes.

## Layout
- `egg-webdesk.json` the egg, import it into a nest
- `images/<distro>/Dockerfile` one folder per distro (ubuntu, debian, kali, parrot, mint, devuan, fedora, rocky, alma, centos, oracle, arch, manjaro, cachyos, alpine, opensuse, void)
- `images/common/` startup scripts shared by every image
- `.github/workflows/build-webdesk.yml` builds every image into `ghcr.io/the-gaming-crib/webdesk:<tag>`

## Setup
1. Actions > build-webdesk > Run workflow. Failed builds do not stop the others.
2. GitHub > Packages > webdesk > Package settings > make Public so Wings can pull.
3. Import `egg-webdesk.json` into a nest. Delete dropdown entries whose build failed.
4. Server: 1 port, 2 GB+ RAM (KDE 3 GB+). Open `http://node-ip:port`, enter the desktop password. Put HTTPS in front.

Status: untested; expect some distros to need Dockerfile fixes after the first build.
