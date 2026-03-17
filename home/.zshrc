# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
# Path your neovim configuration
export MYVIMRC=$HOME/.config/nvim/init.vim
# Set the editor to neovim
export EDITOR=nvim

# Set OS-specific pinentry program for GPG
if [[ "$(uname)" == "Darwin" ]]; then
  _PINENTRY="/opt/homebrew/bin/pinentry-mac"
else
  _PINENTRY="/usr/bin/pinentry"
fi
if ! grep -q "^pinentry-program ${_PINENTRY}$" ~/.gnupg/gpg-agent.conf 2>/dev/null; then
  sed -i.bak '/^pinentry-program /d' ~/.gnupg/gpg-agent.conf 2>/dev/null
  echo "pinentry-program ${_PINENTRY}" >> ~/.gnupg/gpg-agent.conf
  gpgconf --kill gpg-agent 2>/dev/null
fi
unset _PINENTRY

# Source secrets loaded once at login by systemd user service (load-secrets.service)
_SECRETS_ENV="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/secrets-env"
[[ -f "$_SECRETS_ENV" ]] && source "$_SECRETS_ENV"
unset _SECRETS_ENV

# For using avante zen mode
alias avante='nvim -c "lua vim.defer_fn(function()require(\"avante.api\").zen_mode()end, 100)"'

# Powerlevel10k theme
ZSH_THEME="powerlevel10k/powerlevel10k"
POWERLEVEL10K_mode="nerdfont-complete"

# Make homeshick work
fpath=($HOME/.homesick/repos/homeshick/completions $fpath)

# PATH setup — OS-specific entries are conditionalised
export PATH=$HOME/bin:$HOME/.local/bin:$HOME/.homesick/repos/homeshick/bin:$PATH
if [[ "$(uname)" == "Darwin" ]]; then
  export PATH="/opt/homebrew/bin:/opt/homebrew/opt/postgresql@18/bin:$PATH"
else
  export PATH="$HOME/.local/share/gem/ruby/3.4.0/bin:$PATH"
fi

# NVM — load the platform-appropriate version only
export NVM_DIR="$HOME/.nvm"
if [[ "$(uname)" == "Darwin" ]]; then
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
else
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

plugins=(git fzf zsh-autosuggestions tmuxinator)

source $ZSH/oh-my-zsh.sh

# Use vi keybindings in the terminal
bindkey -v
bindkey -s 'jk' '\e'

# Convenience aliases
alias dr='dotnet run'
alias nrd='npm run dev'
alias nrs='npm run start'
alias ni='npm install'
alias yd='yarn dev'
alias ys='yarn start'
alias y='yarn'
alias gc=gcloud
alias k=kubectl
alias clean='rm -rf node_modules package-lock.json yarn.lock'
alias pr='gh pr create --fill | cb-copy'
alias diff="git diff ':!*.lock*'"
alias c=clear
alias tx=tmuxinator

# Make it easy to edit and source configuration
alias ec='nvim ~/.zshrc'
alias sc='source ~/.zshrc'

alias kcontext='k config current-context'
alias klocal='k config use-context minikube'

alias shutdown="sh ~/shutdown_script.sh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[[ $- =~ i ]] && bindkey -r '\ec'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/Downloads/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/Downloads/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc"; fi

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
