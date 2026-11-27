#!/bin/bash
# Xvnc + desktop session + noVNC. Distro independent.
export HOME=/home/container DISPLAY=:1
UID_=$(id -u); GID_=$(id -g)
# Wings runs us as an unnamed uid; give it a passwd entry so desktops don't crash
if ! getent passwd "$UID_" >/dev/null 2>&1 && [ -w /etc/passwd ]; then
  echo "container:x:$UID_:$GID_:container:/home/container:/bin/bash" >> /etc/passwd
fi
export USER=$(id -un 2>/dev/null || echo container) LOGNAME=$USER
PORT="${SERVER_PORT:-6080}"; RES="${RESOLUTION:-1600x900}"; PASS="${VNC_PASSWORD:-changeme}"
mkdir -p "$HOME/.vnc" "$HOME/Desktop" "$HOME/.cache" /tmp/.X11-unix 2>/dev/null
printf '%s\n' "$PASS" | vncpasswd -f > "$HOME/.vnc/passwd"; chmod 600 "$HOME/.vnc/passwd"
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1
export MOZ_FAKE_NO_SANDBOX=1 XDG_RUNTIME_DIR="$HOME/.run" LIBGL_ALWAYS_SOFTWARE=1; mkdir -p "$XDG_RUNTIME_DIR"; chmod 700 "$XDG_RUNTIME_DIR"
Xvnc :1 -geometry "$RES" -depth 24 -rfbauth "$HOME/.vnc/passwd" -rfbport 5901 -localhost \
     -SecurityTypes VncAuth -AlwaysShared >"$HOME/.vnc/xvnc.log" 2>&1 &
XV=$!
for i in $(seq 1 30); do [ -S /tmp/.X11-unix/X1 ] && break; sleep 0.5; done
[ -S /tmp/.X11-unix/X1 ] || { echo "Xvnc failed:"; cat "$HOME/.vnc/xvnc.log"; exit 1; }
SESSION="$(cat /opt/session)"
if command -v dbus-launch >/dev/null; then bash -c "dbus-launch --exit-with-session $SESSION" >"$HOME/.vnc/desktop.log" 2>&1 &
else bash -c "$SESSION" >"$HOME/.vnc/desktop.log" 2>&1 & fi
NOVNC=""; for d in /usr/share/novnc /usr/share/webapps/novnc /usr/share/noVNC; do [ -f "$d/vnc.html" ] && NOVNC=$d && break; done
[ -n "$NOVNC" ] || { echo "noVNC not found in image"; exit 1; }
WEB="$HOME/.web"; rm -rf "$WEB"; mkdir -p "$WEB"
for f in "$NOVNC"/*; do ln -sfn "$f" "$WEB/$(basename "$f")"; done
rm -f "$WEB/index.html"
echo '<meta http-equiv="refresh" content="0;url=vnc.html?autoconnect=true&resize=scale">' > "$WEB/index.html"
websockify --web "$WEB" "$PORT" localhost:5901 &
WS=$!
trap 'kill $WS $XV 2>/dev/null; exit 0' TERM INT
sleep 2; echo "Desktop ready on port $PORT"
wait $WS
