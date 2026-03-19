# dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io) — cross-platform configs for Linux, macOS, and Windows.

## Quick start

```sh
# Install chezmoi and apply dotfiles in one shot
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:dragoscirjan/dotfiles.git
```

Or if chezmoi is already installed:

```sh
chezmoi init --apply git@github.com:dragoscirjan/dotfiles.git
```

## What's inside

| Category | Files / tools |
|---|---|
| **Shell** | `.zshrc`, `.bashrc` — shared via a common `dot_xshrc` template |
| **Prompt** | [oh-my-posh](https://ohmyposh.dev) with a custom `ohmyposh.config.toml` |
| **Terminal** | [Ghostty](https://ghostty.org) · [WezTerm](https://wezfurlong.org/wezterm) |
| **Editor** | [Neovim](https://neovim.io) (external repo) · [Zed](https://zed.dev) · VS Code / VSCodium |
| **Window manager** | [Hyprland](https://hyprland.org) (Linux) · KWin rectangle plugin (Linux/KDE) |
| **Git** | `.gitconfig` with aliases, `amend_and_push` helper, per-org `includeIf` |
| **AI / MCP** | [opencode](https://github.com/sst/opencode) config (external repo) · MCP server install scripts |
| **PowerShell** | Profile with oh-my-posh, cross-platform (Windows + Unix) |

## Platform support

chezmoi templates gate which files are deployed per OS and hostname:

- **Linux** — full setup: Hyprland, KWin, Ghostty, shell configs, MCP scripts
- **macOS** — shell configs, WezTerm, Ghostty skipped (use system defaults), Homebrew paths
- **Windows** — PowerShell profile, WezTerm, AppData configs, WSL awareness

The `.chezmoiignore` file excludes directories that don't apply to the current platform automatically.

## External repos

`.chezmoiexternal.toml` pulls in two git repos and keeps them fresh weekly:

| Target | Source |
|---|---|
| `~/.config/nvim` / `AppData\Local\nvim` | [dragoscirjan/nvim-config](https://github.com/dragoscirjan/nvim-config) |
| `~/.config/opencode` | [dragoscirjan/opencode-config](https://github.com/dragoscirjan/opencode-config) |

## Shell features

Both `.zshrc` and `.bashrc` share a common template (`dot_xshrc`) that provides:

- **`ls` / `la`** — wraps `eza` or `exa` with icons when available, falls back to plain `ls`
- **`cat`** — wraps [`bat`](https://github.com/sharkdp/bat) with plain style when available
- **`cd`** — auto-runs `nvm use` when entering a directory with `.nvmrc`
- **NVM** — auto-installs and activates the `lts/krypton` Node version
- **AI agent launchers** — `opencode`, `oc`, `claude`, `codex`, `gemini`, `kilo`
- **`install_utils`** — bootstraps all tools below from scratch

## Dependencies bootstrapped by `install_utils`

| Tool | Purpose |
|---|---|
| [chezmoi](https://chezmoi.io) | dotfiles manager |
| [oh-my-posh](https://ohmyposh.dev) | shell prompt |
| [mise](https://mise.jdx.dev) | runtime version manager |
| [nvm](https://github.com/nvm-sh/nvm) | Node.js version manager |
| [fzf](https://github.com/junegunn/fzf) | fuzzy finder |
| [Neovim](https://neovim.io) | editor |
| [uv](https://github.com/astral-sh/uv) | Python package manager |
| [Task](https://taskfile.dev) | task runner |
| [autojump](https://github.com/wting/autojump) | directory navigation (non-NixOS) |

## Terminal setup

Both **Ghostty** and **WezTerm** share the same keybinding philosophy:

| Action | Shortcut |
|---|---|
| Next / previous tab | `Ctrl+Shift+L` / `Ctrl+Shift+H` |
| Jump to tab 1–9 | `Ctrl+Shift+1–9` |
| Split horizontally | `Ctrl+Shift+E` |
| Split vertically | `Ctrl+Shift+O` |
| Navigate splits | `Ctrl+Shift+Alt+H/J/K/L` |
| Resize splits | `Alt+Shift+H/J/K/L` |
| Copy / paste | `Ctrl+Insert` / `Shift+Insert` |

Font: **SauceCodePro Nerd Font**, size 16 (13 on `tw-nixos`), background opacity 0.9.

## Git aliases

| Alias | Description |
|---|---|
| `git pll` | Pull from origin with rebase (respects `$PULL_REBASE`) |
| `git psh` | Push to origin current branch |
| `git lol` | Pretty log with author info |
| `git graph` | Graphical commit history |
| `git co` | Checkout shorthand |
| `git c` | Commit shorthand |
| `git amn` | Amend + force-push (`amend_and_push` helper) |
| `git bcp` | Delete all branches except `main` |
| `git m` | Merge (traditional) |
| `git mr` | Merge with rebase |

Work repos under `*/Cellebrite/` automatically pick up a separate identity via `includeIf`.

## MCP servers

On first apply (and whenever the scripts change), chezmoi runs install scripts for:

- `@modelcontextprotocol/server-memory`
- `@modelcontextprotocol/server-sequential-thinking`
- `mcp-memory-libsql`
- TypeScript / Python / Bash language servers (`typescript-language-server`, `pyright`, `bash-language-server`)
- Go tools: `mcp-language-server`, `gopls`

Scripts live in `.chezmoiscripts/` and are skipped gracefully when `go` or `npm` is absent.

## Applying changes

```sh
chezmoi apply          # apply all changes to $HOME
chezmoi diff           # preview what would change
chezmoi update         # pull latest + apply
```

## License

[MIT](LICENSE)
