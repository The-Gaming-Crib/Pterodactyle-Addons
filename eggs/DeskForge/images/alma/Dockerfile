ARG BASE
FROM ${BASE}
ARG EL=0
ARG DE=xfce
RUN if [ "$EL" = 1 ]; then \
      (dnf -y install epel-release || dnf -y install oracle-epel-release-el9) && dnf -y install dnf-plugins-core && \
      (dnf config-manager --set-enabled crb || dnf config-manager --set-enabled ol9_codeready_builder || true) && \
      dnf -y groupinstall "Xfce"; \
    else case "$DE" in \
      xfce) dnf -y install @xfce-desktop-environment ;; \
      kde)  dnf -y install @kde-desktop-environment ;; \
      mate) dnf -y install @mate-desktop-environment ;; \
      lxqt) dnf -y install @lxqt-desktop-environment ;; esac; fi \
 && dnf -y install tigervnc-server-minimal openssh-server firefox xfce4-terminal dbus-x11 \
      google-noto-sans-fonts sudo git nano htop procps-ng which hostname curl wget --skip-broken \
 && (dnf -y install freerdp --skip-broken || true) \
 && dnf clean all
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
# package installs above can recreate /etc/passwd with mode 644, so set this last
RUN chmod 666 /etc/passwd /etc/group
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container
CMD ["/bin/bash", "/entrypoint.sh"]
