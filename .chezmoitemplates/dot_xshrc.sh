export PATH=$HOME/.local/bin:$HOME/bin:$PATH

warn() {
  local YELLOW='\033[1;33m'
  local NC='\033[0m'
  echo -e "${YELLOW}⚠  $*${NC}" >&2
}

[ -d $HOME/.cargo/bin ] && export PATH=$HOME/.cargo/bin:$PATH

# Override cd to
# - auto-use nvm when entering directories with .nvmrc
#
cd() {
  builtin cd $@
  if [ -d "$HOME/.nvm" ] && [ -f .nvmrc ]; then
    nvm use
  fi
}

if command -v exa >/dev/null 2>&1; then
  alias ls='exa --icons'
fi
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons'
fi

# it appears NixOs doesn't like it
#l() {
#  if command -v exa >/dev/null 2>&1; then
#    exa --icons $@
#  else
#    ls $@
#  fi
#}

la() {
  if command -v exa >/dev/null 2>&1; then
    exa --icons -la $@
  else
    if command -v eza >/dev/null 2>&1; then
      eza --icons -la $@
    else
      ls -la $@
    fi
  fi
}

# Autojump -> j
#

# TODO: wonder whether I should replace it with 'z'; but which z ??

# Prefer the autojump installation selected by PATH. This covers Nix profiles,
# NixOS, Homebrew, distro packages, and the default ~/.autojump installer.
# Skip initialization when the NixOS module (or another startup file) loaded it.
if [ "${AUTOJUMP_SOURCED:-}" != "1" ]; then
  autojump_shell=""
  [ -n "$BASH_VERSION" ] && autojump_shell="bash"
  [ -n "$ZSH_VERSION" ] && autojump_shell="zsh"

  autojump_bin="$(command -v autojump 2>/dev/null)"
  autojump_prefix="${autojump_bin%/bin/autojump}"
  [ "$autojump_prefix" = "$autojump_bin" ] && autojump_prefix=""

  for autojump_init in \
    "${autojump_prefix:+$autojump_prefix/share/autojump/autojump.$autojump_shell}" \
    "${autojump_prefix:+$autojump_prefix/etc/profile.d/autojump.sh}" \
    "${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/autojump/autojump.$autojump_shell}" \
    "${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/etc/profile.d/autojump.sh}" \
    "$HOME/.autojump/etc/profile.d/autojump.sh"; do
    [ -n "$autojump_init" ] && [ -r "$autojump_init" ] || continue
    . "$autojump_init"
    break
  done

  unset autojump_bin autojump_init autojump_prefix autojump_shell
fi

# Override cat to use bat (-> https://github.com/sharkdp/bat) if available
#

# TODO: wrap command with if command bat || command batcat ...

cat() {
  local batcmd="- end"
  if [ -z "$NO_BAT" ]; then
    if command -v bat >/dev/null 2>&1; then
      batcmd="bat"
    elif command -v batcat >/dev/null 2>&1; then
      batcmd="batcat"
    fi
  fi
  if [ -n "$batcmd" ]; then
    # Map common cat options to bat equivalents
    local bat_args=()
    local files=()
    while [ $# -gt 0 ]; do
      case "$1" in
      -n)
        bat_args+=("--number")
        ;;
      -b)
        bat_args+=("--number-nonblank")
        ;;
      -s)
        bat_args+=("--squeeze-blank")
        ;;
      -A)
        bat_args+=("--show-all")
        ;;
      -T)
        bat_args+=("--show-tabs")
        ;;
      -E)
        bat_args+=("--show-ends")
        ;;
      --style=*)
        BAT_STYLE="${1#*=}"
        ;;
      --paging=*)
        BAT_PAGING=("${1#*=}")
        ;;
      --)
        shift
        while [ $# -gt 0 ]; do
          files+=("$1")
          shift
        done
        break
        ;;
      -*)
        bat_args+=("$1")
        ;;
      *)
        files+=("$1")
        ;;
      esac
      shift
    done
    BAT_STYLE="plain" BAT_PAGING="never" "$batcmd" "${bat_args[@]}" -- "${files[@]}"
  else
    command cat $@
  fi
}

# OhMyPosh
#

# TODO: Omarchy may fail on loading oh-my-posh
# TODO: should wrap the command under an if command ...
eval "$(oh-my-posh init $(oh-my-posh get shell) --config ~/ohmyposh.config.toml)"

# Neovim
#

[ -d /opt/nvim-linux-x86_64/bin ] && export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
[ -d /home/dragosc/.local/opt/nvim-linux-x86_64/bin ] && export PATH="$PATH:/home/dragosc/.local/opt/nvim-linux-x86_64/bin"

# Preferred editor for local and remote sessions
#
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  if command -v nvim >/dev/null; then
    export EDITOR='nvim'
    v() {
      nvim $@
    }
  else
    export EDITOR='vim'
  fi
fi

t() {
  task $@
}

# Bun
#

if [ -f $HOME/.bun/bin/bun ]; then
  PATH="$HOME/.bun/bin/bun:$PATH"
fi

# Nvm
#

if [ -d "$HOME/.nvm" ]; then
  export NVM_DIR="$HOME/.nvm"

  # This loads nvm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  # This loads nvm bash_completion
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

  export NODE_VERSION="lts/krypton"

  # Check if Node.js is installed and matches the desired version
  INSTALLED_VERSION=$(nvm version $NODE_VERSION)
  if [ "$INSTALLED_VERSION" = "N/A" ]; then
    echo "Node.js $NODE_VERSION not found. Installing..."
    nvm install $NODE_VERSION
  fi
  echo "Using Node.js $NODE_VERSION"
  nvm use $NODE_VERSION
fi

# Npx
#

if command -v npx >/dev/null 2>&1; then
  npx() {
    command npx -y $@
  }
  ai_agent_preload() {
    set -a
    [ -f ./.env.ai ] && source ./.env.ai
    [ -f ./.env ] && source ./.env
    [ -f ~/.env ] && source ~/.env
    set +a

    [ -n "$GITHUB_TOKEN" ] && [ -z "$GH_TOKEN" ] && export GH_TOKEN="$GITHUB_TOKEN"
    [ -n "$GH_TOKEN" ] && [ -z "$GITHUB_TOKEN" ] && export GITHUB_TOKEN="$GH_TOKEN"

    # Browser MCP (playwright/puppeteer)
    [ -z "$BROWSER_PATH" ] && warn "'BROWSER_PATH' is not set. Browser MCP (Playwright/Puppeteer) will not work."

    # CVS: GitHub
    [ -z "$GITHUB_TOKEN" ] && warn "'GITHUB_TOKEN' is not set. GitHub MCP will not work."
    [ -z "$GH_TOKEN" ] && warn "'GH_TOKEN' is not set. GitHub MCP will not work."

    # # CVS: GitLab
    # [ -z "$GITLAB_URL" ] && warn "'GITLAB_URL' is not set. GitLab MCP will not work."

    # # CVS: Forgejo
    # [ -z "$FORGEJO_URL" ] && warn "'FORGEJO_URL' is not set. Forgejo MCP will not work."
    # [ -z "$FORGEJO_ACCESS_TOKEN" ] && warn "'FORGEJO_ACCESS_TOKEN' is not set. Forgejo MCP will not work."

    # # Code Index: CocoIndex
    # [ -z "$COCOINDEX_PATH" ] && warn "'COCOINDEX_PATH' is not set. CocoIndex MCP will not work."
    # [ -z "$COCOINDEX_DB_HOST" ] && warn "'COCOINDEX_DB_HOST' is not set. CocoIndex MCP will not work."
    # [ -z "$COCOINDEX_DB_PORT" ] && warn "'COCOINDEX_DB_PORT' is not set. CocoIndex MCP will not work."
    # [ -z "$COCOINDEX_DB_NAME" ] && warn "'COCOINDEX_DB_NAME' is not set. CocoIndex MCP will not work."
    # [ -z "$COCOINDEX_DB_USER" ] && warn "'COCOINDEX_DB_USER' is not set. CocoIndex MCP will not work."
    # [ -z "$COCOINDEX_DB_PASSWORD" ] && warn "'COCOINDEX_DB_PASSWORD' is not set. CocoIndex MCP will not work."

    # # Code Index: FastCode
    # [ -z "$FASTCODE_PATH" ] && warn "'FASTCODE_PATH' is not set. FastCode MCP will not work."
    # [ -z "$FASTCODE_API_KEY" ] && warn "'FASTCODE_API_KEY' is not set. FastCode MCP will not work."
    # [ -z "$FASTCODE_MODEL" ] && warn "'FASTCODE_MODEL' is not set. FastCode MCP will not work."
    # [ -z "$FASTCODE_BASE_URL" ] && warn "'FASTCODE_BASE_URL' is not set. FastCode MCP will not work."

    # # Web Crawl: Tavily
    # [ -z "$TAVILY_API_KEY" ] && warn "'TAVILY_API_KEY' is not set. Tavily MCP will not work."

    # # Web Crawl: Firecrawl
    # [ -z "$FIRECRAWL_API_KEY" ] && warn "'FIRECRAWL_API_KEY' is not set. Firecrawl MCP will not work."
  }

  ai_agent() {
    ai_agent_preload
    export PROJECT_PATH="$(pwd)"
    npx "${1:-opencode-ai}@latest" "${@:2}"
  }

  claude() {
    #if ! type -P claude >/dev/null 2>&1; then
    if ! command -v claude >/dev/null 2>&1; then
      warn "\`claude\` does not exist; installing..."
      curl -fsSL https://claude.ai/install.sh | bash
    fi
    if [ -n "$UPDATE_CLAUDE" ]; then
      warn "\`claude\` update requested; have some patience..."
      curl -fsSL https://claude.ai/install.sh | bash
    fi
    ai_agent_preload
    command claude "$@"
  }

  codex() {
    ai_agent @openai/codex "$@"
  }

  copilot() {
    ai_agent @github/copilot "$@"
  }

  gemini() {
    ai_agent @google/gemini-cli "$@"
  }

  kilo() {
    ai_agent @kilocode/cli "$@"
  }

  opencode() {
    ai_agent opencode-ai "$@"
  }

  oc() {
    opencode "$@"
  }

  pi() {
    # if ! type -P pi >/dev/null 2>&1; then
    if ! command -v pi >/dev/null 2>&1; then
      warn "\`pi\` does not exist; installing..."
      curl -fsSL https://pi.dev/install.sh | sh
    fi
    if [ -n "$UPDATE_PI" ]; then
      warn "\`pi\` update requested; have some patience..."
      curl -fsSL https://pi.dev/install.sh | sh
    fi
    ai_agent_preload
    command pi "$@"
  }

fi

# Gh
#

if command -v gh >/dev/null 2>&1; then
  gh-dash() {
    set -a
    [ -f ~/.env ] && source ~/.env
    set +a

    gh help | grep dash >/dev/null 2>&1 || gh extension install dlvhdr/gh-dash
    gh dash
  }
fi

# Go
#
[ -d $HOME/go/bin ] && export PATH=$HOME/go/bin:$PATH
