# Vi keybindings in the terminal
set -o vi
bind '"jk":vi-movement-mode'

# Make homeshick work
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
source "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"

# Setup git completion
if [ -f $HOME/.homesick/repos/dotfiles/.git-completion.bash ]; then
	. $HOME/.homesick/repos/dotfiles/.git-completion.bash
fi

export PATH="$HOME/.cargo/bin:$PATH"
