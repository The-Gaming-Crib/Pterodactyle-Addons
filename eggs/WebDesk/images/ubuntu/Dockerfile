ARG BASE
FROM ${BASE}
ARG FF=esr
ARG DE=xfce
ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends \
      tigervnc-standalone-server tigervnc-tools novnc python3-websockify dbus-x11 x11-xserver-utils \
      fonts-noto fonts-noto-color-emoji sudo curl wget git nano htop gnupg ca-certificates procps xdg-utils \
 && case "$DE" in \
      xfce) apt-get install -y --no-install-recommends xfce4 xfce4-terminal thunar mousepad ;; \
      kde)  apt-get install -y --no-install-recommends plasma-desktop kwin-x11 konsole dolphin kate ;; \
      mate) apt-get install -y --no-install-recommends mate-desktop-environment-core mate-terminal caja pluma ;; \
      lxqt) apt-get install -y --no-install-recommends lxqt-core qterminal pcmanfm-qt featherpad ;; \
    esac \
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
RUN chmod +x /opt/start.sh /entrypoint.sh && chmod 666 /etc/passwd && echo "$SESSION" > /opt/session
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container
CMD ["/bin/bash", "/entrypoint.sh"]
