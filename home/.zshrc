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

# Cache pass secrets to avoid GPG lock contention when multiple shells start simultaneously (e.g. tmux)
_PASS_CACHE_DIR="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/pass-cache-$(id -u)"
mkdir -p "$_PASS_CACHE_DIR" && chmod 700 "$_PASS_CACHE_DIR"
_PASS_CACHE_FILE="$_PASS_CACHE_DIR/env"

# Portable file age check (works on both macOS and Linux)
_pass_cache_stale() {
  [[ ! -f "$1" ]] && return 0
  local mtime
  if [[ "$(uname)" == "Darwin" ]]; then
    mtime=$(stat -f %m "$1")
  else
    mtime=$(stat -c %Y "$1")
  fi
  (( $(date +%s) - mtime > 86400 ))
}

if _pass_cache_stale "$_PASS_CACHE_FILE"; then
  # Use mkdir as a portable atomic lock (works on macOS + Linux, unlike flock)
  if mkdir "$_PASS_CACHE_DIR/populating.lock" 2>/dev/null; then
    _OPENAI="$(pass show api_keys/OPENAI_API_KEY 2>/dev/null)"
    _TAVILY="$(pass show api_keys/TAVILY_API_KEY 2>/dev/null)"
    _MORPH="$(pass show api_keys/MORPH_API_KEY 2>/dev/null)"
    _ANTHROPIC="$(pass show api_keys/ANTHROPIC_API_KEY 2>/dev/null)"
    _DOCKER_HUB_PAT="$(pass show AI_development_team/DockerHubPAT 2>/dev/null)"
    cat > "$_PASS_CACHE_FILE" <<CACHE_EOF
export OPENAI_API_KEY="$_OPENAI"
export TAVILY_API_KEY="$_TAVILY"
export MORPH_API_KEY="$_MORPH"
export AVANTE_ANTHROPIC_API_KEY="$_ANTHROPIC"
export _DOCKER_HUB_PAT="$_DOCKER_HUB_PAT"
CACHE_EOF
    chmod 600 "$_PASS_CACHE_FILE"
    rmdir "$_PASS_CACHE_DIR/populating.lock"
    unset _OPENAI _TAVILY _MORPH _ANTHROPIC _DOCKER_HUB_PAT
  fi
fi

if [[ -f "$_PASS_CACHE_FILE" ]]; then
  source "$_PASS_CACHE_FILE"
  [[ -n "$_DOCKER_HUB_PAT" ]] && echo "$_DOCKER_HUB_PAT" | docker login -u niklasmoss --password-stdin 2>/dev/null
  unset _DOCKER_HUB_PAT
else
  # Fallback if cache not yet populated by another shell
  export OPENAI_API_KEY="$(pass show api_keys/OPENAI_API_KEY)"
  export TAVILY_API_KEY="$(pass show api_keys/TAVILY_API_KEY)"
  export MORPH_API_KEY="$(pass show api_keys/MORPH_API_KEY)"
  export AVANTE_ANTHROPIC_API_KEY="$(pass show api_keys/ANTHROPIC_API_KEY)"
  echo "$(pass show AI_development_team/DockerHubPAT)" | docker login -u niklasmoss --password-stdin
fi
unset -f _pass_cache_stale
unset _PASS_CACHE_DIR _PASS_CACHE_FILE

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

alias remote="ssh niklas@192.168.178.137 -t \"tmux -u attach\""

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
