ARG BASE
FROM ${BASE}
ARG DE=xfce
RUN case "$DE" in \
      xfce) P="xfce4 xfce4-terminal thunar mousepad" ;; \
      kde)  P="plasma-desktop plasma-x11-session konsole dolphin kate" ;; \
      mate) P="mate mate-terminal" ;; \
      lxqt) P="lxqt qterminal" ;; esac \
 && (pacman-key --init; pacman-key --populate) >/dev/null 2>&1 || true \
 && pacman -Syu --noconfirm --needed $P tigervnc openssh freerdp firefox dbus ttf-dejavu noto-fonts \
      sudo git nano htop bash procps-ng curl wget xorg-xsetroot \
 && pacman -Scc --noconfirm
RUN (id container >/dev/null 2>&1) || useradd -m -d /home/container -s /bin/bash container
ARG SESSION=startxfce4
COPY common/start.sh /opt/start.sh
COPY common/entrypoint.sh /entrypoint.sh
RUN chmod +x /opt/start.sh /entrypoint.sh && chmod 666 /etc/passwd && echo "$SESSION" > /opt/session
COPY common/sudo.sh /usr/local/bin/sudo
COPY common/install-proot.sh /tmp/install-proot.sh
RUN sh /tmp/install-proot.sh; rm -f /tmp/install-proot.sh; chmod 755 /usr/local/bin/sudo \
 && printf '#!/bin/sh\nexec /usr/local/bin/sudo -i\n' > /usr/local/bin/root && chmod 755 /usr/local/bin/root
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container
CMD ["/bin/bash", "/entrypoint.sh"]
