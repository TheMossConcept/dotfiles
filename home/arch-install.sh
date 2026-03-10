# NB! BEFORE doing anything else, remember to set up systemd-networkd and systemd-resolved. Install, enable and start in systemctl.
# ALSO REMEMBER the following content in /etc/systemd/network/wired.network

# [Match]
# Name=eno1

# [Network]
# DHCP=yes

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
# NB! This line has been known to change across different versions of Arch and diferent versions of keyring. If you get an 
# erro about the user not being in sudoers, check the file manually.
# This line number should work with the Arch version that is used in the Arch Linux
# docker image with image ID 1105a6ef0052. Other known line numbers to work include 85 and 84
sed -i '108s/# //g' /etc/sudoers # Add wheel users with passwords to sudoers. TODO: Find a better way to do this! 
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

# Update all packages using yay
yay -Syu --devel --timeupdate --noconfirm

# Install docker (NB! Only works when systemd is available which is not the case in a Docker container!)
yay -Sy --noconfirm docker
yay -Sy --noconfirm docker-buildx
docker buildx install
yay -Sy --noconfirm docker-compose
usermod -aG docker niklas
systemctl start docker.service
systemctl enable docker.service

yay -Sy --noconfirm docker-compose

# Set up credential manager to enable docker login
yay -Sy --noconfirm docker-credential-pass
yay -Sy --noconfirm pass
yay -Sy --noconfirm gnupg

# Set up Kubernetes. Both gcloud config and kube config is in homeshick
yay -Sy --noconfirm kubectl
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
tar -xf google-cloud-cli-linux-x86_64.tar.gz
./google-cloud-sdk/install.sh
source ~/.zshrc
gcloud components install gke-gcloud-auth-plugin

# Generate key in gnupg
# Do pass init -- key -- with the key just generated (use same password as for LastPass
# Change credsStore in ~/.docker/config.json to be pass instead of desktop
# Do Docker login with the password from docker hub

# Install pinentry to remember the lastpass master password
yay -Sy --noconfirm pinentry

# Intall lastpass and lastpass CLI to be able to access password and access tokens
yay -Sy --noconfirm lastpass-cli # Maybe we need to install lastpass as well but I'm not sure

# Generate SSH key to be able to work with SSH later on. Maybe, we should wait until we actually need it
yay -Sy --noconfirm openssh
ssh-keygen -t ed25519 -C "niklas@themossconcept.com"
eval "$(ssh-agent -s)"

# Install GitHub CLI and authenticate to gain access to your repos including your dotfiles
yay -Sy --noconfirm github-cli
# We need to be root in order to login to lastpass and use it
lpass login niklas.noerregaard@gmail.com 
lpass show --notes 5561560319192977980 | gh auth login --with-token

# Intall homeshick to access your configuration files
git clone https://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
printf '\nsource "$HOME/.homesick/repos/homeshick/homeshick.sh"' >> $HOME/.bashrc
source $HOME/.bashrc

homeshick clone https://github.com/Nnoerregaard/dotfiles.git
homeshick link

# Login to company GitHub to be able to access work repos
lpass show --notes 6835548308542009880 | gh auth login --with-token

# Set up node (needed for neovim)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
# Load nvm for the first use just below. In the future, it's being loaded through .zshrc
source $HOME/.nvm/nvm.sh
nvm install --lts
npm install -g npm # Update npm to latest version
npm install -g neovim # Link our installed node to neovim

# Set up Python needed for neovim, VPN and loads of other stuff 
yay -Sy --noconfirm python311
yay -Sy --noconfirm python-pynvim
yay -Sy --noconfirm python-certifi

yay -S --noconfirm openssl

# Set up xsel for clipboard tool
yay -Sy --noconfirm xsel

# Set up tmux
yay -Sy --noconfirm tmux 
yay -Sy --noconfirm tmuxinator
mkdir /usr/local/share/zsh
mkdir /usr/local/share/zsh/site-functions
wget https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.zsh -O /usr/local/share/zsh/site-functions/_tmuxinator

# This is to make VimPlug work.
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# Needed to make lua_ (fussy finding in vim) work.
yay -Sy --noconfirm rg

# Set up neovim
yay -Sy --noconfirm neovim
# Remember to run PlugInstall and CocInstall on the first neovim run. This hasn't been tested yet!
nvim --headless +'PlugInstall --sync' +qa  
nvim --headless +CocInstall +qa
# This last one is needed to make Denite work
nvim --headless +UpdateRemotePlugins +qa

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
# TODO: This needs to change if the CPU changes. Find a way to automate lspci -v | grep -A1 -e VGA -e 3D  
pacman -Sy --noconfirm xf86-video-intel
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
su niklas --session-command "yay -Si --noconfirm google-chrome"

# Install Todoist CLI
yay -Sy todoist

# Install databases
yay -Sy postgresql

# Set up sensible fonts. The font itself should be set in .Xresources which is symlinked by homeshick
pacman -Sy --noconfirm fontconfig
pacman -Sy --noconfirm extra/xorg-mkfontscale
pacman -Sy --noconfirm ttf-meslo-nerd-font-powerlevel10k
fc-cache -f -v

# Install autocutsel to synchronise clipboards
yay -Sy autocutsel

# Turn the TTF directory into a font dir for use by X11!
cd /usr/share/fonts/TTF
mkfontdir 
cd ~

# Install oh my zsh 
yay -Sy --noconfirm zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --keep-zshrc"

# Start the final terminal after configuration is set up
zsh -c "source ~/.zshrc && su niklas"

