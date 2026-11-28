#!/bin/bash
# DeskForge: Xvnc (X server) + desktop session, exposed ONLY via the protocols you pick: rdp, vnc, ssh. No web UI.
export HOME=/home/container DISPLAY=:1
UID_=$(id -u); GID_=$(id -g)
# Wings runs us as an arbitrary uid that may collide with a system account (e.g. sshd, shell nologin)
# or have no passwd entry at all. Make sure this uid resolves to a real login entry named "container".
if [ "$(getent passwd "$UID_" | cut -d: -f1)" != "container" ]; then
  ENTRY="container:x:$UID_:$GID_:container:/home/container:/bin/bash"
  TMPF="$HOME/.passwd.df"
  if { echo "$ENTRY"; cat /etc/passwd; } > "$TMPF" 2>/dev/null && cat "$TMPF" > /etc/passwd 2>/dev/null; then :
  elif echo "$ENTRY" >> /etc/passwd 2>/dev/null; then :
  else echo "WARNING: cannot write /etc/passwd (uid $UID_ has no user entry); desktop may fail"; fi
  rm -f "$TMPF"
fi
getent group "$GID_" >/dev/null 2>&1 || echo "container:x:$GID_:" >> /etc/group 2>/dev/null
echo "Running as: $(getent passwd "$UID_" || echo "uid $UID_ unresolved")"
export SHELL=/bin/bash
export USER=$(id -un 2>/dev/null || echo container) LOGNAME=$USER
export PATH="$PATH:/usr/sbin:/sbin:/usr/local/sbin"
BASE="${SERVER_PORT:-3389}"; RES="${RESOLUTION:-1600x900}"; PASS="${DESKTOP_PASSWORD:-changeme}"
RDP_USER="${RDP_USER:-desktop}"; ACCESS="${ACCESS:-rdp}"
# Ports: first selected protocol gets SERVER_PORT, then +1, +2 (order: rdp, vnc, ssh). Add matching allocations in the panel.
declare -A WANT PORT; n=0
for p in $(echo "$ACCESS" | tr '+,' '  '); do WANT[$p]=1; done
[ "${WANT[all]}" = 1 ] && WANT[rdp]=1 && WANT[vnc]=1 && WANT[ssh]=1
for p in rdp vnc ssh; do [ "${WANT[$p]}" = 1 ] && { PORT[$p]=$((BASE+n)); n=$((n+1)); }; done
mkdir -p "$HOME/.vnc" "$HOME/Desktop" "$HOME/.cache" "$HOME/.ssh" "$HOME/.rdp" /tmp/.X11-unix 2>/dev/null
for A in prism steam-fex; do [ -f /usr/share/applications/$A.desktop ] && [ ! -e "$HOME/Desktop/$A.desktop" ] && cp /usr/share/applications/$A.desktop "$HOME/Desktop/" && chmod +x "$HOME/Desktop/$A.desktop"; done
printf '%s\n' "$PASS" | vncpasswd -f > "$HOME/.vnc/passwd"; chmod 600 "$HOME/.vnc/passwd"
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1
export MOZ_FAKE_NO_SANDBOX=1 XDG_RUNTIME_DIR="$HOME/.run" LIBGL_ALWAYS_SOFTWARE=1; mkdir -p "$XDG_RUNTIME_DIR"; chmod 700 "$XDG_RUNTIME_DIR"
# X server. VNC is internet-facing only if "vnc" was selected; otherwise it listens on localhost:5901 (SSH tunnel use).
if [ -n "${PORT[vnc]}" ]; then VNCARGS="-rfbport ${PORT[vnc]}"; else VNCARGS="-rfbport 5901 -localhost"; fi
Xvnc :1 -geometry "$RES" -depth 24 -rfbauth "$HOME/.vnc/passwd" $VNCARGS -SecurityTypes VncAuth -AlwaysShared >"$HOME/.vnc/xvnc.log" 2>&1 &
XV=$!; PIDS="$XV"
for i in $(seq 1 30); do [ -S /tmp/.X11-unix/X1 ] && break; sleep 0.5; done
[ -S /tmp/.X11-unix/X1 ] || { echo "Xvnc failed:"; cat "$HOME/.vnc/xvnc.log"; exit 1; }
SESSION="$(cat /opt/session)"
if command -v dbus-launch >/dev/null; then bash -c "dbus-launch --exit-with-session $SESSION" >"$HOME/.vnc/desktop.log" 2>&1 &
else bash -c "$SESSION" >"$HOME/.vnc/desktop.log" 2>&1 & fi
PIDS="$PIDS $!"; OK=0
[ -n "${PORT[vnc]}" ] && { echo "VNC  listening on port ${PORT[vnc]} (password: Desktop password, first 8 chars)"; OK=1; }
if [ -n "${PORT[rdp]}" ]; then
  HASH=$(command -v winpr-hash || command -v winpr-hash3 || command -v winpr-hash2)
  SHADOW=$(command -v freerdp-shadow-cli || command -v freerdp-shadow-cli3 || command -v freerdp-shadow-cli2)
  if [ -n "$HASH" ] && [ -n "$SHADOW" ]; then
    "$HASH" -u "$RDP_USER" -p "$PASS" > "$HOME/.rdp/sam" 2>/dev/null
    "$SHADOW" /port:"${PORT[rdp]}" /sec:nla /sam-file:"$HOME/.rdp/sam" -auth >"$HOME/.rdp/rdp.log" 2>&1 &
    PIDS="$PIDS $!"; echo "RDP  listening on port ${PORT[rdp]} (user: $RDP_USER, password: Desktop password)"; OK=1
  else echo "WARNING: RDP tools (freerdp shadow server) are not in this image - pick a different distro or use vnc/ssh"; fi
fi
if [ -n "${PORT[ssh]}" ]; then
  if [ -n "$SSH_PUBKEY" ]; then
    chmod 700 "$HOME/.ssh"; printf '%s\n' "$SSH_PUBKEY" > "$HOME/.ssh/authorized_keys"; chmod 600 "$HOME/.ssh/authorized_keys"
    [ -f "$HOME/.ssh/host_ed25519" ] || ssh-keygen -q -t ed25519 -N '' -f "$HOME/.ssh/host_ed25519"
    cat > "$HOME/.ssh/sshd_config" <<CFG
Port ${PORT[ssh]}
HostKey $HOME/.ssh/host_ed25519
PidFile $HOME/.ssh/sshd.pid
AuthorizedKeysFile $HOME/.ssh/authorized_keys
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
UsePAM no
StrictModes no
X11Forwarding yes
AllowTcpForwarding yes
Subsystem sftp internal-sftp
CFG
    SSHD=$(command -v sshd)
    if [ -n "$SSHD" ]; then "$SSHD" -D -e -f "$HOME/.ssh/sshd_config" >"$HOME/.ssh/sshd.log" 2>&1 & PIDS="$PIDS $!"
      echo "SSH  listening on port ${PORT[ssh]} (user: $USER, key login only). Desktop via tunnel: ssh -p ${PORT[ssh]} -L 5901:localhost:5901 $USER@HOST then VNC to localhost:5901"; OK=1
    else echo "WARNING: sshd not found in this image"; fi
  else echo "WARNING: ssh selected but 'SSH public key' variable is empty - skipping ssh"; fi
fi
[ "$OK" = 1 ] || { echo "No remote-access protocol started. Check the Access variable / image."; exit 1; }
trap 'kill $PIDS 2>/dev/null; exit 0' TERM INT
sleep 2; echo "Desktop ready"
wait $XV
