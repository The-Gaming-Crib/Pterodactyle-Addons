#!/bin/sh
# Installs Prism Launcher (Minecraft, CurseForge packs) + Java + software-GL libs into /opt/prism, any distro.
# Alpine (musl) cannot run the glibc AppImage, so it is skipped there.
set -u
if command -v apk >/dev/null 2>&1; then echo "games: skipped on Alpine (musl)"; rm -f /usr/share/applications/prism.desktop; exit 0; fi
if command -v apt-get >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive; apt-get update
  apt-get install -y --no-install-recommends libgl1-mesa-dri libegl1 libxcb-cursor0 libxcb-xinerama0 zenity xz-utils squashfs-tools wget ca-certificates
  apt-get install -y --no-install-recommends openjdk-21-jre || apt-get install -y --no-install-recommends openjdk-17-jre
  apt-get install -y --no-install-recommends openjdk-17-jre || true
  rm -rf /var/lib/apt/lists/*
elif command -v dnf >/dev/null 2>&1; then
  dnf install -y mesa-dri-drivers mesa-libEGL xcb-util-cursor zenity xz wget --setopt=install_weak_deps=False || true
  dnf install -y java-21-openjdk || dnf install -y java-17-openjdk || true
  dnf install -y java-17-openjdk || true; dnf clean all
elif command -v pacman >/dev/null 2>&1; then
  pacman -S --noconfirm --needed mesa libglvnd xcb-util-cursor zenity xz wget jre21-openjdk jre17-openjdk || true; pacman -Scc --noconfirm
elif command -v zypper >/dev/null 2>&1; then
  zypper -n install Mesa-dri Mesa-libEGL1 libxcb-cursor0 zenity xz wget java-21-openjdk java-17-openjdk || true; zypper clean -a
elif command -v xbps-install >/dev/null 2>&1; then
  xbps-install -Sy mesa-dri libEGL xcb-util-cursor zenity xz wget openjdk21-jre openjdk17-jre || true
fi
A=$(uname -m)
U="https://github.com/PrismLauncher/PrismLauncher/releases/download/11.1.1/PrismLauncher-Linux-$A.AppImage"
if command -v curl >/dev/null 2>&1; then curl -fsSL "$U" -o /tmp/prism.AppImage; else wget -q "$U" -O /tmp/prism.AppImage; fi
if [ -s /tmp/prism.AppImage ]; then
  chmod +x /tmp/prism.AppImage && cd /opt && /tmp/prism.AppImage --appimage-extract >/dev/null 2>&1 && mv squashfs-root prism && chmod -R a+rX /opt/prism
fi
rm -f /tmp/prism.AppImage
[ -x /opt/prism/AppRun ] || { echo "games: Prism install failed"; rm -f /usr/share/applications/prism.desktop; }
exit 0
