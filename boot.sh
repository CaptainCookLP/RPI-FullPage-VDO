#!/bin/bash

# Update und Upgrade der Paketlisten
sudo apt-get update && sudo apt-get upgrade -y

# Installation von Xserver, Openbox und Chromium
sudo apt-get install --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox chromium-browser -y 

# Bearbeiten der Openbox-Autostartdatei
sudo tee /etc/xdg/openbox/autostart > /dev/null <<EOF
# Disable any form of screen saver / screen blanking / power management
xset s off
xset s noblank
xset -dpms

# Allow quitting the X server with CTRL-ATL-Backspace
setxkbmap -option terminate:ctrl_alt_bksp

# Start Chromium in kiosk mode
sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' ~/.config/chromium/'Local State'
sed -i 's/"exited_cleanly":false/"exited_cleanly":true/; s/"exit_type":"[^"]\+"/"exit_type":"Normal"/' ~/.config/chromium/Default/Preferences
chromium-browser --autoplay-policy=no-user-gesture-required --disable-infobars --kiosk 'https://fkmedify.com/live1'
EOF

# Bearbeiten der .bash_profile-Datei
echo '[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && startx -- -nocursor' >> ~/.bash_profile

# Bearbeiten der autologin.conf-Datei für den automatischen Login
sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin pi --noclear %I 38400 linux
EOF

# Bearbeiten der cmdline.txt-Datei
sudo sed -i 's/$/ consoleblank=1 loglevel=0/' /boot/cmdline.txt

# Bearbeiten der config.txt-Datei
echo 'disable_splash=1' | sudo tee -a /boot/config.txt > /dev/null

# Neustart des Systems
sudo reboot
