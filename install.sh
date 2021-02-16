#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

cd /tmp || exit
mkdir "dell_install"

apt update
echo 'Installing dependencies...'

apt install -y curl

curl -sL https://deb.nodesource.com/setup_15.x | sudo -E bash -

apt install -y dkms git docker nodejs tlp

echo "Installing Google Chrome..."

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i google-chrome-stable_current_amd64.deb

echo "Installing Magic mouse 2 driver ..."

git clone "https://github.com/RicardoEPRodrigues/Linux-Magic-Trackpad-2-Driver.git"
cd Linux-Magic-Trackpad-2-Driver || exit
chmod u+x install.sh
sudo ./install.sh

echo "Installing IntelliJ IDEA..."
wget "https://download.jetbrains.com/product?code=IIU&latest&distribution=linux" -O idea.tar.gz
tar -zxf idea.tar.gz -C /opt
/opt/idea-IU-*/bin/idea.sh

echo "Checking sleep mode..."

if ! grep "\[deep\]" /sys/power/mem_sleep; then
  sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& mem_sleep_default=deep/' /etc/default/grub
fi

echo "Fix grub fonts..."

grub-mkfont -s 32 -o /boot/grub/fonts/DejaVuSansMono.pf2 /usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf
echo "GRUB_FONT=/boot/grub/fonts/DejaVuSansMono.pf2" >> /etc/default/grub
update-grub
