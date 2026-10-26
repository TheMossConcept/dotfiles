#!/bin/bash
set -euo pipefail
trap 'echo "ERROR: line $LINENO: $BASH_COMMAND" >&2' ERR

# Run as root on a freshly booted Arch install, with these files next to this script:
#   arch-install-phase2.sh, macbook-air-public-key.pub, pass-key.asc
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
USER_NAME=niklas
USER_HOME=/home/$USER_NAME

[[ $EUID -eq 0 ]] || { echo "Run this script as root" >&2; exit 1; }
for f in arch-install-phase2.sh macbook-air-public-key.pub pass-key.asc; do
    [[ -f "$SCRIPT_DIR/$f" ]] || { echo "Missing $SCRIPT_DIR/$f" >&2; exit 1; }
done

as_user() { sudo -u "$USER_NAME" -H -- "$@"; }

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

# Make sure the pacman keyring is initialised and current before installing anything,
# then do a full upgrade (pacman -Sy followed by single installs is a partial upgrade)
pacman-key --init
pacman-key --populate archlinux
pacman -Sy --needed --noconfirm archlinux-keyring
pacman -Su --noconfirm

# Install every package available in the official repositories (AUR packages are installed in phase 2)
pacman -S --needed --noconfirm \
    zsh git git-zsh-completion sudo sed jq man-db man-pages curl wget unzip lsof \
    base-devel openssh ntp \
    xorg-server xorg-xinit xorg-xrandr xorg-xlsfonts xorg-xset xorg-mkfontscale xterm \
    i3-wm i3status i3blocks i3lock dmenu xss-lock dex \
    fontconfig ttf-hack-nerd \
    pipewire pipewire-pulse wireplumber pavucontrol \
    bluez bluez-utils tailscale keyd \
    docker docker-buildx docker-compose \
    pass gnupg pinentry github-cli \
    python-pynvim python-certifi python-pip uv rust openssl \
    xsel xclip tmux ripgrep neovim tree-sitter-cli fzf act \
    maim firefox postgresql

# Ensure system clock is always updated
systemctl enable --now ntpd.service

# Add user that can work with sudo
id "$USER_NAME" &>/dev/null || useradd -m -G wheel -s /bin/zsh "$USER_NAME"
echo "$USER_NAME:iPhone3gs" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
visudo -c # Check that the sudoers file is still valid

# Let the user run sudo without a password while this script runs (yay/makepkg call sudo pacman)
TEMP_SUDOERS=/etc/sudoers.d/99-arch-install-nopasswd
echo "$USER_NAME ALL=(ALL:ALL) NOPASSWD: ALL" > "$TEMP_SUDOERS"
chmod 440 "$TEMP_SUDOERS"
trap 'rm -f "$TEMP_SUDOERS"' EXIT

# Install yay to access all community packages
if ! command -v yay &>/dev/null; then
    rm -rf /opt/yay-bin
    git clone https://aur.archlinux.org/yay-bin.git /opt/yay-bin
    chown -R "$USER_NAME:$USER_NAME" /opt/yay-bin
    as_user bash -c "cd /opt/yay-bin && makepkg -si --noconfirm --needed"
fi

# Install ngrok
curl -fsSL https://bin.ngrok.com/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz --output /tmp/ngrok.tgz
tar -xzf /tmp/ngrok.tgz -C /usr/local/bin
rm -f /tmp/ngrok.tgz

# Set up openssh access through other machines
install -d -m 700 -o "$USER_NAME" -g "$USER_NAME" "$USER_HOME/.ssh"
PUBKEY="$(cat "$SCRIPT_DIR/macbook-air-public-key.pub")"
grep -qxF "$PUBKEY" "$USER_HOME/.ssh/authorized_keys" 2>/dev/null || echo "$PUBKEY" >> "$USER_HOME/.ssh/authorized_keys"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/.ssh/authorized_keys"
chmod 600 "$USER_HOME/.ssh/authorized_keys"
cat << 'EOF' > /etc/ssh/sshd_config.d/10-key-only.conf
PasswordAuthentication no
PubkeyAuthentication yes
EOF
systemctl enable --now sshd

# Import the GPG key for pass into the user's keyring (not root's) and trust it ultimately
GPG_KEY_ID=$(gpg --with-colons --import-options show-only --import "$SCRIPT_DIR/pass-key.asc" | awk -F: '/^fpr:/{print $10; exit}')
as_user gpg --batch --import < "$SCRIPT_DIR/pass-key.asc"
echo "$GPG_KEY_ID:6:" | as_user gpg --import-ownertrust
gpgconf --kill all

# Bluetooth and tailscale (run "sudo tailscale up" once to log in)
systemctl enable --now bluetooth.service
systemctl enable --now tailscaled.service

# Docker
usermod -aG docker "$USER_NAME"
systemctl enable --now docker.service

# =============================================================================
# Phase 2: User setup (run as niklas)
# =============================================================================

# Copy phase 2 script to niklas's home (root's home is not readable by niklas)
install -m 755 -o "$USER_NAME" -g "$USER_NAME" "$SCRIPT_DIR/arch-install-phase2.sh" "$USER_HOME/arch-install-phase2.sh"
# Not a login shell: on re-runs, the linked ~/.zprofile would try to load secrets and log in to docker
as_user bash "$USER_HOME/arch-install-phase2.sh"

# =============================================================================
# Phase 3: Final root-level setup (needs dotfiles and AUR packages from phase 2)
# =============================================================================

# Keyboard remapping
install -d /etc/keyd
cp "$USER_HOME/.config/keyd/COPY_OF_KEYD_CONFIG_THIS_DOES_NOT_DO_ANYTHING.conf" /etc/keyd/default.conf
systemctl enable keyd
systemctl restart keyd

# Make the fonts (incl. the AUR powerlevel10k font) available to X11
fc-cache -f
if [[ -d /usr/share/fonts/TTF ]]; then (cd /usr/share/fonts/TTF && mkfontscale && mkfontdir); fi

# Never blank the screen
install -d /etc/X11/xorg.conf.d
cat << 'EOF' > /etc/X11/xorg.conf.d/10-no-dpms.conf
Section "ServerFlags"
    Option "StandbyTime" "0"
    Option "SuspendTime" "0"
    Option "OffTime" "0"
    Option "BlankTime" "0"
EndSection

Section "Extensions"
    Option "DPMS" "false"
EndSection
EOF

# tmuxinator zsh completion
install -d /usr/local/share/zsh/site-functions
curl -fsSL https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.zsh \
    -o /usr/local/share/zsh/site-functions/_tmuxinator

echo ""
echo "============================================="
echo " Setup complete! Remaining manual steps:"
echo "   sudo tailscale up     (log in to tailscale)"
echo "   reboot, log in as $USER_NAME and run: startx"
echo "============================================="
