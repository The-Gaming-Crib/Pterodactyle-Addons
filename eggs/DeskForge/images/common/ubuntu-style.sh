#!/bin/sh
# Make the XFCE desktop look like stock Ubuntu: Yaru theme, Ubuntu wallpaper, dock on the left.
X=/etc/xdg/xfce4/xfconf/xfce-perchannel-xml; mkdir -p "$X" /etc/xdg/autostart
cat > "$X/xsettings.xml" <<XML
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty"><property name="ThemeName" type="string" value="Yaru"/><property name="IconThemeName" type="string" value="Yaru"/></property>
  <property name="Gtk" type="empty"><property name="FontName" type="string" value="Sans 10"/></property>
</channel>
XML
cat > "$X/xfwm4.xml" <<XML
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0"><property name="general" type="empty"><property name="theme" type="string" value="Yaru"/><property name="button_layout" type="string" value="|HMC"/></property></channel>
XML
W=$(ls /usr/share/backgrounds/*.jpg /usr/share/backgrounds/*.png 2>/dev/null | head -1)
if [ -n "$W" ]; then
  P=""; for m in monitorVNC-0 monitor0 monitorscreen; do
    P="$P<property name=\"$m\" type=\"empty\"><property name=\"workspace0\" type=\"empty\"><property name=\"last-image\" type=\"string\" value=\"$W\"/><property name=\"image-style\" type=\"int\" value=\"5\"/></property></property>"
  done
  cat > "$X/xfce4-desktop.xml" <<XML
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0"><property name="backdrop" type="empty"><property name="screen0" type="empty">$P</property></property></channel>
XML
fi
if command -v plank >/dev/null; then
  mkdir -p /usr/share/glib-2.0/schemas
  printf "[net.launchpad.plank.dock.settings]\nposition='left'\ntheme='Gtk+'\nicon-size=44\nhide-mode='none'\n" > /usr/share/glib-2.0/schemas/99-deskforge-plank.gschema.override
  glib-compile-schemas /usr/share/glib-2.0/schemas 2>/dev/null || true
  printf "[Desktop Entry]\nType=Application\nName=Dock\nExec=plank\nX-GNOME-Autostart-enabled=true\n" > /etc/xdg/autostart/plank.desktop
fi
