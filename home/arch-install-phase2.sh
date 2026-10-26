#!/bin/bash
set -euo pipefail
trap 'echo "ERROR: line $LINENO: $BASH_COMMAND" >&2' ERR

# =============================================================================
# Phase 2: User setup (run as niklas, started by arch-install.sh)
# =============================================================================

# Let gpg-agent ask for the pass key's passphrase on this terminal
if tty -s; then export GPG_TTY="$(tty)"; fi

# Install AUR packages (official packages are installed by arch-install.sh)
yay -S --needed --noconfirm --removemake \
    lastpass-cli docker-credential-pass mons todoist-bin python311 tmuxinator \
    ttf-meslo-nerd-font-powerlevel10k \
    google-chrome infisical-bin railwayapp-cli mongodb-bin mongosh-bin

# Set up claude code
curl -fsSL https://claude.ai/install.sh | bash

# Generate SSH key
[[ -f ~/.ssh/id_ed25519 ]] || ssh-keygen -t ed25519 -C "niklas@themossconcept.com" -N "" -f ~/.ssh/id_ed25519

# Authenticate GitHub CLI with the token stored in LastPass, and let git use it
LPASS_DISABLE_PINENTRY=1 lpass login niklas.noerregaard@gmail.com
lpass show --notes 6835548308542009880 | gh auth login --with-token
gh auth setup-git
gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(cat /etc/hostname 2>/dev/null || echo arch)" \
    || echo "WARNING: could not add SSH key to GitHub (token may lack admin:public_key scope)" >&2

# Pull secrets after having authenticated with GitHub
[[ -d ~/.password-store ]] || git clone https://github.com/TheMossConcept/Secrets.git ~/.password-store

# Set up ngrok authentication
ngrok config add-authtoken "$(pass show AI_development_team/ngrok_auth_token)"

# Install homeshick to access configuration files
[[ -d ~/.homesick/repos/homeshick ]] || git clone https://github.com/andsens/homeshick.git ~/.homesick/repos/homeshick
source ~/.homesick/repos/homeshick/homeshick.sh

# Pull dotfiles and automated development team files and link those in the environment
# (--force replaces the skeleton files from useradd and the ~/.gitconfig written by gh)
for repo in dotfiles Automated-development-team; do
    [[ -d ~/.homesick/repos/$repo ]] || homeshick --batch clone "https://github.com/TheMossConcept/$repo.git"
done
homeshick --batch --force link

# Install oh-my-zsh (non-interactive, keep the linked .zshrc), powerlevel10k and zsh-autosuggestions
ZSH_CUSTOM=~/.oh-my-zsh/custom
[[ -d ~/.oh-my-zsh ]] || RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
[[ -d $ZSH_CUSTOM/themes/powerlevel10k ]] || git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
[[ -d $ZSH_CUSTOM/plugins/zsh-autosuggestions ]] || git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

# Set up node (needed for neovim). PROFILE=/dev/null stops nvm editing the linked .zshrc,
# and nvm.sh is not compatible with "set -u"
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | PROFILE=/dev/null bash
set +u
source ~/.nvm/nvm.sh
nvm install --lts
set -u
npm install -g npm neovim

# Docker uses pass to store registry credentials
mkdir -p ~/.docker
[[ -f ~/.docker/config.json ]] || echo '{ "credsStore": "pass" }' > ~/.docker/config.json

# Enable Danish letters and other Unicode characters produced by keyd
ln -sf /usr/share/keyd/keyd.compose ~/.XCompose

# Pre-install neovim plugins headlessly
export EDITOR=nvim
nvim --headless '+Lazy! sync' +qa

# Stop the gpg daemons started by this script; their sockets live in ~/.gnupg because no login
# session exists, so a real login would start a second keyboxd that deadlocks on the keybox lock
gpgconf --kill all

echo 'Phase 2 complete!'
