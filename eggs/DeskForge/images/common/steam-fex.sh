#!/bin/bash
# Steam on ARM via FEX-Emu (x86 emulation, no KVM). First run downloads the x86 rootfs and Steam (~1-2 GB).
export HOME=${HOME:-/home/container}
S="$HOME/.local/share/Steam"
mkdir -p "$HOME/.fex-emu" "$S"
if [ ! -d "$HOME/.fex-emu/RootFS" ] || [ -z "$(ls -A "$HOME/.fex-emu/RootFS" 2>/dev/null)" ]; then
  echo "First run: downloading the x86 root filesystem for FEX (one time)..."
  FEXRootFSFetcher -y -x || { echo "Rootfs download failed"; read -rp "Press Enter"; exit 1; }
fi
if [ ! -x "$S/steam.sh" ]; then
  echo "First run: downloading Steam..."
  T=$(mktemp -d); curl -fsSL https://repo.steampowered.com/steam/archive/stable/steam_latest.deb -o "$T/s.deb" \
    && dpkg -x "$T/s.deb" "$T/x" && tar -xf "$T/x/usr/lib/steam/bootstraplinux_ubuntu12_32.tar.xz" -C "$S" \
    || { echo "Steam download failed"; read -rp "Press Enter"; exit 1; }
  rm -rf "$T"
fi
export LIBGL_ALWAYS_SOFTWARE=1 STEAM_RUNTIME=0
# FEXBash treats its argument as a script file name, so run bash through FEXInterpreter explicitly.
exec FEXInterpreter /usr/bin/bash -c "'$S/steam.sh' -no-cef-sandbox -cef-disable-gpu -cef-disable-gpu-compositing"
