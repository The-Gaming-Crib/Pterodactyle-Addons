ARG BASE
FROM ${BASE}
RUN xbps-install -Syu xbps && xbps-install -Sy xfce4 xfce4-terminal tigervnc openssh freerdp firefox dbus bash sudo \
      git nano htop curl wget shadow noto-fonts-ttf procps-ng && xbps-remove -O
RUN (id container >/dev/null 2>&1) || useradd -m -d /home/container -s /bin/bash container
ARG SESSION=startxfce4
COPY common/start.sh /opt/start.sh
COPY common/entrypoint.sh /entrypoint.sh
RUN chmod +x /opt/start.sh /entrypoint.sh && chmod 666 /etc/passwd /etc/group && echo "$SESSION" > /opt/session
COPY common/sudo.sh /usr/local/bin/sudo
COPY common/install-proot.sh /tmp/install-proot.sh
RUN sh /tmp/install-proot.sh; rm -f /tmp/install-proot.sh; chmod 755 /usr/local/bin/sudo \
 && printf '#!/bin/sh\nexec /usr/local/bin/sudo -i\n' > /usr/local/bin/root && chmod 755 /usr/local/bin/root
COPY common/prism.desktop /usr/share/applications/prism.desktop
COPY common/install-games.sh /tmp/install-games.sh
RUN sh /tmp/install-games.sh; rm -f /tmp/install-games.sh
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container
CMD ["/bin/bash", "/entrypoint.sh"]
