#!/bin/bash
set -euo pipefail

# =============================================================================
# Phase 1: Root setup (run as root)
# =============================================================================

# Setup up DHCP for DNS resolution
cat << 'EOF' > /etc/systemd/network/20-wired.network
[Match]
Name=en*

[Network]
DHCP=yes
EOF

systemctl enable --now systemd-networkd
systemctl enable --now systemd-resolved

ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# Sync pacman database once
pacman -Sy --noconfirm

# Reset pacman keys as package installations fail if one is missing or out of date
pacman -S --noconfirm archlinux-keyring
pacman-key --init
pacman-key --populate

# Ensure system clock is always updated
pacman -S --noconfirm ntp
systemctl enable ntpd.service
systemctl start ntpd.service

# Install zsh early so we can set it as the default shell for niklas
pacman -S --noconfirm zsh

# Install core tools needed for the rest of the setup
pacman -S --noconfirm \
    glibc git git-zsh-completion sudo sed jq man-db man-pages curl \
    base-devel openssh

# Add user that can work with sudo
useradd -m -G wheel -s /bin/zsh niklas
echo "niklas:iPhone3gs" | chpasswd
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers
visudo -c # Check that the sudoers file is still valid

# Install yay to access all community packages
(
    cd /opt
    git clone https://aur.archlinux.org/yay-bin.git
    chown -R niklas yay-bin/
    cd yay-bin
    git config --global --add safe.directory /opt/yay-bin
    su niklas --session-command "makepkg -si --noconfirm"
)

# Install ngrok
curl -fsSL https://bin.ngrok.com/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz --output /tmp/ngrok.tgz
tar -xvzf /tmp/ngrok.tgz -C /usr/local/bin
rm -f /tmp/ngrok.tgz

# Install X11, i3, and fonts (root-level pacman installs)
pacman -S --noconfirm \
    xorg-server xorg-xinit xterm xorg-xrandr xorg-xlsfonts \
    i3 i3status dmenu xss-lock i3lock dex \
    fontconfig extra/xorg-mkfontscale ttf-meslo-nerd-font-powerlevel10k

fc-cache -f -v

# Turn the TTF directory into a font dir for use by X11
(cd /usr/share/fonts/TTF && mkfontdir)

# Set up openssh access through other machines
mkdir -p /home/niklas/.ssh
cat macbook-air-public-key.pub >> /home/niklas/.ssh/authorized_keys
chown -R niklas:niklas /home/niklas/.ssh
chmod 700 /home/niklas/.ssh
chmod 600 /home/niklas/.ssh/authorized_keys
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
systemctl start sshd
systemctl enable sshd

# Set up GPG key for pass (needs to be done as root for import, then niklas for pass init)
gpg --import pass-key.asc
GPG_KEY_ID=$(gpg --with-colons --import-options show-only --import pass-key.asc | awk -F: '/^fpr:/{print $10; exit}')
echo -e "5\ny\nsave\n" | gpg --command-fd 0 --edit-key "$GPG_KEY_ID" trust

# Create tmuxinator completion directory
mkdir -p /usr/local/share/zsh/site-functions

# =============================================================================
# Phase 2: User setup (run as niklas)
# =============================================================================

# Copy phase 2 script to niklas's home and make it executable
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cp "$SCRIPT_DIR/arch-install-phase2.sh" /home/niklas/arch-install-phase2.sh
chown niklas:niklas /home/niklas/arch-install-phase2.sh
chmod +x /home/niklas/arch-install-phase2.sh

su niklas --login -c "/home/niklas/arch-install-phase2.sh '$GPG_KEY_ID'"

# =============================================================================
# Phase 3: Final root-level service setup (after packages are installed)
# =============================================================================

# Docker service (packages were installed by yay in phase 2)
docker buildx install
usermod -aG docker niklas
systemctl start docker.service
systemctl enable docker.service

# Keyd service
systemctl enable keyd && systemctl start keyd

echo ""
echo "============================================="
echo " Setup complete! Log in as niklas and run:"
echo "   startx"
echo "============================================="
