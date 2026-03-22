set -euo pipefail

# =============================================================================
# Phase 2: User setup (run as niklas)
# =============================================================================

GPG_KEY_ID="$1"

# Update all packages using yay
 yay -Syu --devel --timeupdate --noconfirm

# Set up claude code
 curl -fsSL https://claude.ai/install.sh | bash

# Install docker
 yay -S --noconfirm docker docker-buildx docker-compose

# Install credential management, secrets, and auth tools
 yay -S --noconfirm \
    docker-credential-pass pass gnupg pinentry \
    lastpass-cli github-cli

# Install dev tools
yay -S --noconfirm \
    python311 python-pynvim python-certifi openssl \
    xclip tmux tmuxinator ripgrep neovim \
    mons maim firefox todoist postgresql

# Install keyd for keyboard remapping
yay -S --noconfirm keyd-git

# Set up pass (secret store)
pass init "$GPG_KEY_ID"
pass git init
pass git remote add origin https://github.com/TheMossConcept/Secrets.git

# Generate SSH key
ssh-keygen -t ed25519 -C "niklas@themossconcept.com" -N ""
eval "$(ssh-agent -s)"

# Install GitHub CLI and authenticate
lpass login niklas.noerregaard@gmail.com
lpass show --notes 6835548308542009880 | gh auth login --with-token

# Pull secrets after having authenticated with GitHub
pass git pull

# Set up ngrok authentication
ngrok config add-authtoken $(pass show AI_development_team/ngrok_auth_token)

# Install homeshick to access configuration files
 git clone https://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
source $HOME/.homesick/repos/homeshick/homeshick.sh

# Pull dotfiles and automated development team files and link those in the environment
homeshick clone https://github.com/TheMossConcept/dotfiles.git
homeshick clone https://github.com/TheMossConcept/Automated-development-team.git
 homeshick link

# Set up node (needed for neovim)
 curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source $HOME/.nvm/nvm.sh
nvm install --lts
npm install -g npm neovim

# To make treesitter work
yay -S tree-sitter-cli

# Download tmuxinator zsh completion
curl -fsSL https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.zsh -o /usr/local/share/zsh/site-functions/_tmuxinator

# Install oh-my-zsh (non-interactive, keep existing .zshrc)
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc

# Install powerlevel10k theme
# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Install zsh-autosuggestions plugin
# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Install fzf
yay -S --noconfirm fzf

# Install bun
# curl -fsSL https://bun.sh/install | bash

# Set up keyd config
sudo cp ~/.config/keyd/COPY_OF_KEYD_CONFIG_THIS_DOES_NOT_DO_ANYTHING.conf /etc/keyd/default.conf
# To enable Danish letters and other Unicode extended characters
setxkbmap -option compose:menu
ln -s /usr/share/keyd/keyd.compose ~/.XCompose

# Pre-install neovim plugins headlessly
export EDITOR=nvim
nvim --headless '+Lazy! sync' +qa

echo 'Phase 2 complete!'
