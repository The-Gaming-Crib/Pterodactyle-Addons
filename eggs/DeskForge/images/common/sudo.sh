#!/bin/bash
# DeskForge "fake root": real root inside a private copy of the OS, via proot.
# Looks and acts like root (apt/pacman/dnf install work) but cannot touch the host
# or other servers. Packages live in ~/.rootfs, so they survive restarts.
export HOME=${HOME:-/home/container}
R="$HOME/.rootfs"
command -v proot >/dev/null || { echo "proot is missing from this image" >&2; exit 1; }
if [ ! -e "$R/.ready" ]; then
  echo "First use: creating your private root filesystem (one time, may take a minute)..." >&2
  mkdir -p "$R"
  for d in bin sbin lib lib32 lib64 libx32 usr etc var opt srv root; do
    [ -e "/$d" ] && cp -a "/$d" "$R/" 2>/dev/null
  done
  mkdir -p "$R"/{proc,sys,dev,tmp,home,run,mnt,root}
  [ -d "$R/etc/apt" ] && mkdir -p "$R/etc/apt/apt.conf.d" && echo 'APT::Sandbox::User "root";' > "$R/etc/apt/apt.conf.d/99deskforge"
  [ -f "$R/etc/pacman.conf" ] && sed -i 's/^#\?DisableSandbox.*//; s/^\[options\]/[options]\nDisableSandbox/' "$R/etc/pacman.conf" 2>/dev/null
  touch "$R/.ready"
fi
case "$1" in -u|-E|-H|-n|-k|-A) shift ;; esac
if [ $# -eq 0 ] || [ "$1" = "-i" ] || [ "$1" = "-s" ] || [ "$1" = "su" ] || [ "$1" = "-" ]; then
  [ $# -gt 0 ] && shift
  set -- /bin/bash -l
fi
exec proot -0 -r "$R" -b /proc -b /sys -b /dev -b /tmp -b /etc/resolv.conf -b "$HOME" -w "${PWD:-/}" \
  env HOME=/root USER=root LOGNAME=root PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin "$@"
