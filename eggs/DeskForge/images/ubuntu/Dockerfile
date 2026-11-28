ARG BASE
FROM ${BASE}
ARG FF=esr
ARG DE=xfce
ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends \
      tigervnc-standalone-server tigervnc-tools openssh-server dbus-x11 x11-xserver-utils \
      fonts-noto fonts-noto-color-emoji sudo curl wget git nano htop gnupg ca-certificates procps xdg-utils \
 && case "$DE" in \
      xfce) apt-get install -y --no-install-recommends xfce4 xfce4-terminal thunar mousepad ;; \
      kde)  apt-get install -y --no-install-recommends plasma-desktop kwin-x11 konsole dolphin kate ;; \
      mate) apt-get install -y --no-install-recommends mate-desktop-environment-core mate-terminal caja pluma ;; \
      lxqt) apt-get install -y --no-install-recommends lxqt-core qterminal pcmanfm-qt featherpad ;; \
    esac \
 && (apt-get install -y --no-install-recommends freerdp3-shadow-x11 winpr3-utils || apt-get install -y --no-install-recommends freerdp2-shadow-x11 winpr-utils || true) \
 && if [ "$FF" = mozilla ]; then \
      install -d -m 0755 /etc/apt/keyrings && \
      wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O /etc/apt/keyrings/packages.mozilla.org.asc && \
      echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" > /etc/apt/sources.list.d/mozilla.list && \
      printf 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n' > /etc/apt/preferences.d/mozilla && \
      apt-get update && apt-get install -y firefox; \
    else apt-get install -y firefox-esr || apt-get install -y firefox; fi \
 && apt-get purge -y xfce4-screensaver light-locker 2>/dev/null; apt-get autoremove -y; rm -rf /var/lib/apt/lists/*
RUN (id container >/dev/null 2>&1) || useradd -m -d /home/container -s /bin/bash container
ARG SESSION=startxfce4
COPY common/start.sh /opt/start.sh
COPY common/entrypoint.sh /entrypoint.sh
RUN chmod +x /opt/start.sh /entrypoint.sh && chmod 666 /etc/passwd /etc/group && echo "$SESSION" > /opt/session
COPY common/sudo.sh /usr/local/bin/sudo
COPY common/install-proot.sh /tmp/install-proot.sh
RUN sh /tmp/install-proot.sh; rm -f /tmp/install-proot.sh; chmod 755 /usr/local/bin/sudo \
 && printf '#!/bin/sh\nexec /usr/local/bin/sudo -i\n' > /usr/local/bin/root && chmod 755 /usr/local/bin/root
ARG GAMES=no
COPY common/steam-fex.sh /usr/local/bin/steam-fex
COPY common/steam.desktop /usr/share/applications/steam-fex.desktop
COPY common/prism.desktop /usr/share/applications/prism.desktop
RUN chmod 755 /usr/local/bin/steam-fex; \
    if [ "$GAMES" = yes ]; then \
      apt-get update && apt-get install -y --no-install-recommends libgl1-mesa-dri libegl1 libxcb-cursor0 libxcb-xinerama0 \
        openjdk-21-jre openjdk-17-jre zenity xz-utils squashfs-tools && \
      A=$(uname -m) && \
      wget -q "https://github.com/PrismLauncher/PrismLauncher/releases/download/11.1.1/PrismLauncher-Linux-$A.AppImage" -O /tmp/prism.AppImage && \
      chmod +x /tmp/prism.AppImage && cd /opt && /tmp/prism.AppImage --appimage-extract >/dev/null && mv squashfs-root prism && \
      chmod -R a+rX /opt/prism && rm -f /tmp/prism.AppImage && cd / ; \
      if [ "$(dpkg --print-architecture)" = arm64 ]; then \
        apt-get install -y software-properties-common erofs-utils squashfuse && \
        add-apt-repository -y ppa:fex-emu/fex && apt-get update && apt-get install -y fex-emu-armv8.2; \
      else rm -f /usr/share/applications/steam-fex.desktop /usr/local/bin/steam-fex; fi; \
      rm -rf /var/lib/apt/lists/*; \
    else rm -f /usr/share/applications/steam-fex.desktop /usr/local/bin/steam-fex /usr/share/applications/prism.desktop; fi
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container
CMD ["/bin/bash", "/entrypoint.sh"]
