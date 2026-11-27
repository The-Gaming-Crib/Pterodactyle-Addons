ARG BASE
FROM ${BASE}
RUN apk add --no-cache bash xfce4 xfce4-terminal thunar mousepad dbus dbus-x11 tigervnc openssh-server openssh-sftp-server \
      firefox ttf-dejavu font-noto-emoji sudo git nano htop procps shadow curl wget
RUN apk add --no-cache freerdp || true
RUN (id container >/dev/null 2>&1) || adduser -D -h /home/container -s /bin/bash container
ARG SESSION=startxfce4
COPY common/start.sh /opt/start.sh
COPY common/entrypoint.sh /entrypoint.sh
RUN chmod +x /opt/start.sh /entrypoint.sh && chmod 666 /etc/passwd && echo "$SESSION" > /opt/session
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container
CMD ["/bin/bash", "/entrypoint.sh"]
