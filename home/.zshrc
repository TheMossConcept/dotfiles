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
# Set correct ASPNET Core environment
export ASPNETCORE_ENVIRONMENT=Local
# Set the editor to neovim
export EDITOR=nvim

LPASS_AGENT_DISABLE=0
LPASS_AGENT_TIMEOUT=86400

export OPENAI_API_KEY="$(pass show api_keys/OPENAI_API_KEY)"
export TAVILY_API_KEY="$(pass show api_keys/TAVILY_API_KEY)"
export MORPH_API_KEY="$(pass show api_keys/MORPH_API_KEY)"
export AVANTE_ANTHROPIC_API_KEY="$(pass show api_keys/ANTHROPIC_API_KEY)"
echo $(pass show AI_development_team/DockerHubPAT) | docker login -u niklasmoss --password-stdin

# For using avante zen mode
alias avante='nvim -c "lua vim.defer_fn(function()require(\"avante.api\").zen_mode()end, 100)"'

# Gets powerlevel10k to use as zsh theme 
[ ! -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k ] && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel10k/powerlevel10k"
POWERLEVEL10K_mode="nerdfont-complete"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

#Make homeshick work
fpath=($HOME/.homesick/repos/homeshick/completions $fpath)


# Setup nvm on Mac OS X with homebrew
# Set up the path to include everything I need from Python to nvim to binaries in various locations. Remember to clean this up from time to time!
export ANDROID_PLATFORM_TOOLS='/Users/niklasmoss/Library/Android/sdk/platform-tools/' 
export PATH=$HOME/bin:/usr/local/bin:/opt/homebrew/bin:/usr/local/bin/nvim-osx64/bin:/Library/Frameworks/Python.framework/Versions/3.7/bin:/$HOME/.homesick/repos/homeshick/bin:/opt/google/chrome:/home/niklas/.local/share/gem/ruby/3.4.0/bin:$PATH

# NB! NVM needs to be the last command to modify the path, otherwise, it'll always default to system, see https://github.com/nvm-sh/nvm/issues/1184 

# Setup NVM on Unix
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm on Mac OS X
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion on Mac OS X

# Setup NVM on Linux
export NVM_DIR="$HOME/.nvm"
 [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
 [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Installs fzf for fuzzy finding
[ ! -d ~/.fzf ] && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && yes | ~/.fzf/install
# Installs zsh autosuggestions for terminal autosuggestions
[ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ] && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# Gets the Hack font for terminal use
[ ! -f ~/.local/share/fonts/Hack\ Nerd\ Font\ Complete.ttf ] && curl --silent -fLo ~/.local/share/fonts/Hack\ Nerd\ Font\ Complete.ttf --create-dirs https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git fzf zsh-autosuggestions tmuxinator)

source $ZSH/oh-my-zsh.sh

# Syncrhonise clipboards for sane copy/pasting
if command -v autocutsel
then
  autocutsel -f
  echo "Ran autocutsel -f to syncrhonise clipboards with autocutsel present" 
fi;

# Use vi keybindings in the termianl because they are awesome!
bindkey -v
# use jk as alias for escape, to enter normal mode
bindkey -s 'jk' '\e'

# Convinience aliases
alias dr='dotnet run'
alias nrd='npm run dev'
alias nrs='npm run start'
alias ni='npm install'
alias yd='yarn dev'
alias ys='yarn start'
alias y='yarn'
alias es='expo start'
alias gc=gcloud
alias k=kubectl
alias clean='rm -rf node_modules package-lock.json yarn.lock'
# This is seriously awesome! Creates a GitHub PR from your current branch towards master and copies the link of it to your clipboard 
alias pr='gh pr create --fill | xsel -p -s -b'
alias diff="git diff ':!*.lock*'"
alias c=clear
alias tx=tmuxinator
alias todo=todoist-cli
#alias print='maim --format=png --select screenshot.png'

# Make it easy to edit and source configuration
alias ec='nvim ~/.zshrc'
alias sc='source ~/.zshrc'

alias kcontext='k config current-context'
alias klocal='k config use-context minikube'

alias shutdown="sh ~/shutdown_script.sh"

# Bestseller stuff
alias kdev='k config use-context gke_planning-pri-dev-b0b9_europe-west4_planning01-dev'
alias ktest='k config use-context gke_planning-pri-dev-b0b9_europe-west4_planning01-test'
alias kprod='k config use-context gke_planning-pri-prod-976d_europe-west4_planning01-prod'
alias kmaterial='k config use-context gke_products-pri-dev-9052_europe-west4_bsoneproduct02-dev'

alias bsvpn='cd /home/niklas/vpn/openfortivpn-webview-modified/openfortivpn-webview-electron && npm run --silent start "dk-vpn.bestseller.com:444/remote/saml/start?realm=external&redirect=1" > VPN_COOKIE_FILE && cat VPN_COOKIE_FILE | sudo openfortivpn dk-vpn.bestseller.com:444 --realm=external --cookie-on-stdin --trusted-cert 7144fcce659cf305ea3bf452681533f8229906ea816fd0ad02fe848f52d10e0d' 

export CUSTOM_USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
alias google-chrome='google-chrome --disable-device-emulation --user-agent=$CUSTOM_USER_AGENT &> /dev/null'
export QTWEBENGINE_CHROMIUM_FLAGS='--disable-device-emulation --user-agent=$CUSTOM_USER_AGENT'

# Todoist shorthands

alias focus="todo sync && todo list --filter '@Focus'"
alias quick="todo sync && todo list --filter '@Quick'"
alias research="todo sync && todo list --filter '@Research'"

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"



# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[[ $- =~ i ]] && bindkey -r '\ec'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# Load Angular CLI autocompletion.
# source <(ng completion script)

# . "$HOME/.local/bin/env"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/niklas/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/home/niklas/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/niklas/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/niklas/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

#Update dotfiles and passwords
homeshick pull dotfiles
homeshick link
pass git pull
export PATH="$HOME/.local/bin:$PATH"
