# Set macOS-specific pinentry program for GPG
if [[ "$(uname)" == "Darwin" ]]; then
  sed -i.bak 's|^pinentry-program .*|pinentry-program /opt/homebrew/bin/pinentry-mac|' ~/.gnupg/gpg-agent.conf
  gpgconf --kill gpg-agent 2>/dev/null
fi

# Load secrets from pass and log into Docker — runs once per login session.
# Unlike .zshrc (which runs per-shell), .zprofile only runs for login shells.

_SECRETS_ENV="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/secrets-env"

if [[ ! -f "$_SECRETS_ENV" ]]; then
  OPENAI="$(pass show api_keys/OPENAI_API_KEY)"
  TAVILY="$(pass show api_keys/TAVILY_API_KEY)"
  MORPH="$(pass show api_keys/MORPH_API_KEY)"
  ANTHROPIC="$(pass show api_keys/ANTHROPIC_API_KEY)"
  DOCKER_HUB_PAT="$(pass show AI_development_team/DockerHubPAT)"

  cat > "$_SECRETS_ENV" <<EOF
export OPENAI_API_KEY="$OPENAI"
export TAVILY_API_KEY="$TAVILY"
export MORPH_API_KEY="$MORPH"
export AVANTE_ANTHROPIC_API_KEY="$ANTHROPIC"
EOF
  chmod 600 "$_SECRETS_ENV"

  echo "$DOCKER_HUB_PAT" | docker login -u niklasmoss --password-stdin

  unset OPENAI TAVILY MORPH ANTHROPIC DOCKER_HUB_PAT
fi

source "$_SECRETS_ENV"
unset _SECRETS_ENV
