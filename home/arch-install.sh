# Setup up DHCP for DNS resolution so I can access  
cat << 'EOF' > /etc/systemd/network/20-wired.network
[Match]
Name=en*

[Network]
DHCP=yes
EOF

systemctl enable --now systemd-networkd
systemctl enable --now systemd-resolved

ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# Update pacman
pacman -Sy --noconfirm

pacman -Sy --noconfirm man-db man-pages

# Ensure system clock is always updated
pacman -Sy --noconfirm ntp
systemctl enable ntpd.service
systemctl start ntpd.service

# Reset pacman keys as package installations fail if one is missing or out of date
pacman -Sy --noconfirm archlinux-keyring
pacman-key --init
pacman-key --populate

# This is necessary in order for git to work
pacman -Sy --noconfirm glibc

# Install git to do setup and also just for general development
pacman -Sy --noconfirm git
# Install sudo to check the validity of the sudoer file after modification
pacman -Sy --noconfirm sudo
# Install sed to modify the sudoer file (and other files) in a non-interactive way
pacman -Sy --noconfirm sed

# Add user that can work with sudo
useradd -m -G wheel -s /bin/bash niklas
passwd niklas
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers
visudo -c # Check that the sudoers file is still valid

# Install yay to access all community packages
pacman -Sy --noconfirm base-devel
cd /opt
git clone https://aur.archlinux.org/yay-bin.git
chown niklas yay-bin/
cd yay-bin
git config --global --add safe.directory /opt/yay-bin
su niklas --session-command "makepkg -si --noconfirm"

# Go home again
cd ~
# Ensure we are now running as user niklas so all our setup wouldn't be done for root but rather or niklas 
su niklas

# Update all packages using yay
yay -Syu --devel --timeupdate --noconfirm

# Set up claude code
curl -fsSL https://claude.ai/install.sh | bash

# Install docker (NB! Only works when systemd is available which is not the case in a Docker container!)
yay -Sy --noconfirm docker
yay -Sy --noconfirm docker-buildx
docker buildx install
yay -Sy --noconfirm docker-compose
usermod -aG docker niklas
systemctl start docker.service
systemctl enable docker.service

yay -Sy --noconfirm docker-compose

# Set up credential manager to enable docker login and access to secrets
yay -Sy --noconfirm docker-credential-pass
yay -Sy --noconfirm pass
yay -Sy --noconfirm gnupg

# Set up secret store
su
gpg --import pass-key.asc
# TODO: Verify that the id of the key is correct!
echo -e "5\ny\nsave\n" | gpg --command-fd 0 --edit-key D651D2F437AD293D65F4BEB85B156575468E0A26 trust
su niklas
pass init D651D2F437AD293D65F4BEB85B156575468E0A26 
pass git init
pass git remote add origin git@github.com:TheMossConcept/Secrets.git

# Install pinentry to remember the lastpass master password
yay -Sy --noconfirm pinentry

# Intall lastpass and lastpass CLI to be able to access password and access tokens
yay -Sy --noconfirm lastpass-cli # Maybe we need to install lastpass as well but I'm not sure

# Generate SSH key to be able to work with SSH later on. Maybe, we should wait until we actually need it
yay -Sy --noconfirm openssh
ssh-keygen -t ed25519 -C "niklas@themossconcept.com"
eval "$(ssh-agent -s)"

# Set up openssh access through other machines - we need to be root to do this
cat macbook-air-public-key.pub >> ~/.ssh/authorized_keys
su
echo PasswordAuthentication no >> /etc/ssh/sshd_config
echo PubkeyAuthentication yes >> /etc/ssh/sshd_config
systemctl start sshd
systemctl enable sshd
su niklas

# Install GitHub CLI and authenticate to gain access to your repos including your dotfiles
yay -Sy --noconfirm github-cli
# We need to be root in order to login to lastpass and use it
lpass login niklas.noerregaard@gmail.com 
lpass show --notes 6835548308542009880 | gh auth login --with-toke

# Pull secrets after having authenticated with GitHub
pass git pull

# Intall homeshick to access your configuration files
git clone https://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
printf '\nsource "$HOME/.homesick/repos/homeshick/homeshick.sh"' >> $HOME/.bashrc
source $HOME/.bashrc

homeshick clone https://github.com/TheMossConcept/dotfiles.git
homeshick link

# Set up node (needed for neovim)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
# Load nvm for the first use just below. In the future, it's being loaded through .zshrc
source $HOME/.nvm/nvm.sh
nvm install --lts
npm install -g npm # Update npm to latest version
npm install -g neovim # Install neovim through npm so it is linked to 

# Set up Python needed for neovim, VPN and loads of other stuff 
yay -Sy --noconfirm python311
yay -Sy --noconfirm python-pynvim
yay -Sy --noconfirm python-certifi

yay -S --noconfirm openssl

# Set up xclip for clipboard tool (used by cb-copy/cb-paste wrappers)
yay -Sy --noconfirm xclip

# Set up tmux
yay -Sy --noconfirm tmux 
yay -Sy --noconfirm tmuxinator
mkdir /usr/local/share/zsh
mkdir /usr/local/share/zsh/site-functions
wget https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.zsh -O /usr/local/share/zsh/site-functions/_tmuxinator

# Needed to make lua_ (fussy finding in vim) work.
yay -Sy --noconfirm rg

# Set up neovim
yay -Sy --noconfirm neovim

export EDITOR=nvim

# Install keyd for keyboard remapping, most noticeably remapping caps lock to ctrl 
cd ~
yay -Sy keyd-git
sudo cp ~/.config/keyd/COPY_OF_KEYD_CONFIG_THIS_DOES_NOT_DO_ANYTHING.conf /etc/keyd/default.conf
# To enable Danish letters and other Unicode extended characters
setxkbmap -option compose:menu 
ln -s /usr/share/keyd/keyd.compose ~/.XCompose 
sudo systemctl enable keyd && sudo systemctl start keyd

# Install X11 (consider switching to Waryland!) and i3 to acheive better colors, fonts and to use chrome
pacman -Sy --noconfirm xorg-server
pacman -Sy --noconfirm xorg-xinit
# TODO: The proper visual driver should have been installed during arch installation. If that is not the case, displays wouldn't work!
pacman -Sy virtualbox
pacman -Sy --noconfirm xterm
pacman -Sy --noconfirm xorg-xrandr
pacman -Sy --noconfirm xorg-xlsfonts
pacman -Sy --noconfirm i3

# Install mons to allow me to easily work with multiple monitors
yay -Sy --noconfirm mons

# Used for taking screenshots from the terminal with i3 shortcuts
yay -Sy --noconfirm maim

# Install google chrome
su niklas --session-command "yay -Sy --noconfirm firefox"

# Install Todoist CLI
yay -Sy todoist

# Install databases
yay -Sy postgresql

# Set up sensible fonts. The font itself should be set in .Xresources which is symlinked by homeshick
pacman -Sy --noconfirm fontconfig
pacman -Sy --noconfirm extra/xorg-mkfontscale
pacman -Sy --noconfirm ttf-meslo-nerd-font-powerlevel10k
fc-cache -f -v


# Turn the TTF directory into a font dir for use by X11!
cd /usr/share/fonts/TTF
mkfontdir 
cd ~

# Install oh my zsh 
yay -Sy --noconfirm zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --keep-zshrc"

# Start the final terminal after configuration is set up
zsh -c "source ~/.zshrc && startx && echo SETUP COMPLETE"
