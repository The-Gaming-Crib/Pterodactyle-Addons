#!/bin/sh
# Static proot from upstream; works on every distro and both CPU architectures.
A=$(uname -m); case "$A" in x86_64) A=x86_64 ;; aarch64|arm64) A=aarch64 ;; esac
U="https://github.com/proot-me/proot/releases/download/v5.3.0/proot-v5.3.0-$A-static"
if command -v curl >/dev/null; then curl -fsSL "$U" -o /usr/local/bin/proot
else wget -q "$U" -O /usr/local/bin/proot; fi
chmod 755 /usr/local/bin/proot
