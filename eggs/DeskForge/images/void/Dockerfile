ARG BASE
FROM ${BASE}
RUN xbps-install -Syu xbps && xbps-install -Sy xfce4 xfce4-terminal tigervnc openssh freerdp firefox dbus bash sudo \
      git nano htop curl wget shadow noto-fonts-ttf procps-ng && xbps-remove -O
RUN (id container >/dev/null 2>&1) || useradd -m -d /home/container -s /bin/bash container
ARG SESSION=startxfce4
COPY common/start.sh /opt/start.sh
COPY common/entrypoint.sh /entrypoint.sh
RUN chmod +x /opt/start.sh /entrypoint.sh && chmod 666 /etc/passwd && echo "$SESSION" > /opt/session
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container
CMD ["/bin/bash", "/entrypoint.sh"]
