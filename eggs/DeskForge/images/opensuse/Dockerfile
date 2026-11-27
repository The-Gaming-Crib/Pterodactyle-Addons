ARG BASE
FROM ${BASE}
RUN zypper -n in -t pattern xfce && zypper -n in tigervnc openssh MozillaFirefox \
      xfce4-terminal dbus-1-x11 bash sudo git nano htop procps hostname curl wget shadow && zypper clean -a
RUN zypper -n in freerdp || true
RUN (id container >/dev/null 2>&1) || useradd -m -d /home/container -s /bin/bash container
ARG SESSION=startxfce4
COPY common/start.sh /opt/start.sh
COPY common/entrypoint.sh /entrypoint.sh
RUN chmod +x /opt/start.sh /entrypoint.sh && chmod 666 /etc/passwd && echo "$SESSION" > /opt/session
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container
CMD ["/bin/bash", "/entrypoint.sh"]
