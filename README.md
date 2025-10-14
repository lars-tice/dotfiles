# Lars' Dotfiles

My personal dotfiles for macOS and Linux, managed with GNU Stow and Ansible.

## Installation

### Quick Start

Clone this repository and run the bootstrap script:

```bash
git clone https://github.com/lars-tice/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x bootstrap.sh
./bootstrap.sh
```

The bootstrap script will:
1. Install [uv](https://github.com/astral-sh/uv) (Fast Python package manager)
2. Use uv to install Ansible (no system Python required!)
3. Prompt for your sudo password (needed for package installation)
4. Run the Ansible playbook to install all dependencies
5. Stow dotfiles configurations

**Note**: On Linux, the script will prompt for your sudo password to install packages via `apt`.

### Installation Modes

**Normal Mode** (default): Adopts existing local configurations
```bash
./bootstrap.sh
```

**Force Mode**: Prioritizes dotfiles over local configs (backs up existing)
```bash
./bootstrap.sh --extra-vars "force_config=true"
```

### Testing Changes (Dry-Run)

Before making actual changes, you can preview what would happen using Ansible's check mode:

```bash
# Basic dry-run
./bootstrap.sh --check --diff

# Dry-run with force mode
./bootstrap.sh --extra-vars "force_config=true" --check --diff
```

**What each flag does:**
- `--check`: Ansible's dry-run mode (no actual changes)
- `--diff`: Shows the actual differences that would be made

**Note**: The script will still prompt for your sudo password even in check mode, as Ansible needs to validate access permissions. Your password won't be used to make actual changes.

**What gets protected in check mode:**
- ✅ Package installations (brew, apt) - simulated only
- ✅ File modifications (stow operations, config copies) - simulated only
- ✅ Service restarts (keyd restart) - simulated only
- ✅ System alternatives (setting default terminal) - simulated only

**What still executes (prerequisites for running the check):**
- ⚠️ `uv` installation (needed to run Ansible)
- ⚠️ `ansible-core` installation (needed to run the playbook)
- ⚠️ Ansible collection installation (needed for modules)

These prerequisites are idempotent and safe to run multiple times.

**Other useful commands:**

```bash
# List all tasks that would run
./bootstrap.sh --list-tasks

# List available tags (if defined)
./bootstrap.sh --list-tags
```

**Recommended workflow:**

1. **Review tasks**: `./bootstrap.sh --list-tasks`
2. **Dry-run**: `./bootstrap.sh --extra-vars "force_config=true" --check --diff`
3. **Review output**: Examine what would change
4. **Execute**: `./bootstrap.sh --extra-vars "force_config=true"`

### Architecture Philosophy

This setup uses a **Python-free approach** for dependency management:
- **uv** manages all Python needs (never install Python system-wide!)
- **Ansible** is installed via uv as an isolated tool
- Zero Python version conflicts
- Faster, more reliable installations

## What's Included

### Configurations
- **zsh**: Shell configuration with aliases and environment variables
- **git**: Git configuration with delta for better diffs
- **nvim**: Neovim configuration with LazyVim, Tokyo Night theme, and Telescope integrations
- **ghostty**: Ghostty terminal configuration with transparency and Tokyo Night theme
- **starship**: Cross-shell prompt with Git integration and Tokyo Night theme
- **tmux**: Terminal multiplexer with custom keybindings and Tokyo Night theme

### Platform-Specific Configurations
- **aerospace** (macOS): AeroSpace tiling window manager configuration
- **karabiner** (macOS): Karabiner-Elements keyboard customization
- **keyd** (Linux): Keyboard remapping daemon configuration

### Cross-Platform Tools

#### Core Tools
- **git**: Version control
- **gh**: GitHub CLI (macOS via brew, Linux requires [manual install](https://cli.github.com/manual/installation))
- **neovim**: Modern Vim-based editor
- **stow**: Symlink farm manager for dotfiles

#### Security Tools
- **gnupg**: GNU Privacy Guard for encryption and signing (macOS only via brew)
- **git-crypt**: Transparent file encryption in git repositories (macOS only via brew)
- **Git Credential Manager**: Cross-platform credential helper (Linux only)

#### Development Tools
- **ripgrep**: Fast recursive grep
- **fd** / **fd-find**: Fast file finder (fd on macOS, fd-find on Linux)
- **fzf**: Fuzzy finder
- **lazygit**: Terminal UI for git (macOS only via brew)
- **git-delta**: Better git diffs with syntax highlighting (macOS only via brew)
- **uv**: Fast Python package manager by Astral
- **glow**: Beautiful markdown reader for terminal (macOS only via brew)

#### Shell Enhancements
- **starship**: Cross-shell prompt
- **bat**: Better `cat` with syntax highlighting
- **tmux**: Terminal multiplexer
- **atuin**: Shell history database with search (macOS only via brew)
- **eza**: Modern `ls` replacement with icons (macOS only via brew, Linux requires [manual install](https://github.com/eza-community/eza/blob/main/INSTALL.md))
- **zoxide**: Smarter `cd` that learns your habits (macOS only via brew)

### Platform-Specific Tools

#### macOS Only
- **Ghostty**: Modern terminal emulator (via Homebrew cask)
- **AeroSpace**: Tiling window manager (via Homebrew tap)
- **Karabiner-Elements**: Advanced keyboard customization
- **JetBrains Mono Nerd Font**: Programming font with icons (via Homebrew cask)

#### Linux Only
- **Ghostty**: Modern terminal emulator (via .deb package)
- **keyd**: System-wide keyboard remapping daemon
- **xclip**: X11 clipboard integration
- **JetBrains Mono Nerd Font**: Programming font with icons (via direct download)
- **Git Credential Manager**: For Azure DevOps authentication

## Manual Stowing

If you need to stow individual configurations manually:

```bash
cd ~/dotfiles

# Cross-platform
stow zsh
stow git
stow nvim
stow ghostty
stow starship
stow tmux

# macOS only
stow @macos
stow aerospace
stow karabiner

# Linux only
# Note: keyd requires sudo and is handled by Ansible
```

To unstow (remove symlinks):
```bash
stow -D zsh
```

## Workflow: Development vs Deployment

### Development Machine Workflow
When actively developing dotfiles on your main machine:

1. **Edit configs directly** in `~/dotfiles/` (they're already symlinked)
2. **Test changes** immediately (symlinks mean changes are live)
3. **Commit desired changes** to git
4. **Push to GitHub**
5. **Don't run install scripts** on development machine (configs already linked)

### Deployment Machine Workflow
When deploying to a new or existing machine:

1. **Clone dotfiles**: `git clone https://github.com/lars-tice/dotfiles.git ~/dotfiles`
2. **Choose mode**:
   - Normal: `./bootstrap.sh` (adopts local configs)
   - Force: `./bootstrap.sh --extra-vars "force_config=true"` (dotfiles win)
3. **Review changes**: Check any `.backup.*` files created in force mode
4. **Reload shell**: `source ~/.zshrc` or `source ~/.bashrc`

### Pre-Deployment Best Practice

**Important**: Always commit and push dotfiles changes before running `bootstrap.sh` on deployment machines.

**Why this matters:**
- ✅ **Safety**: Git backup of your configuration
- ✅ **Reproducibility**: Other machines can pull the same changes
- ✅ **Revertibility**: Can use `git revert` if something goes wrong
- ✅ **Documentation**: Git history shows what changed when
- ✅ **Sync**: Your repo reflects what's actually deployed

**Recommended order:**

```bash
cd ~/dotfiles

# 1. Check what's changed
git status
git diff

# 2. Review uncommitted changes carefully
# Make sure these are the changes you want to deploy

# 3. Commit and push to make git the source of truth
git add -A
git commit -m "Update configs before deployment"
git push origin main

# 4. Optional: Dry-run first (see Testing Changes section)
./bootstrap.sh --extra-vars "force_config=true" --check --diff

# 5. Deploy to target machine
./bootstrap.sh --extra-vars "force_config=true"
```

**When you can skip committing first:**
- Testing on a throwaway machine
- Experimenting with changes you plan to discard
- Using dry-run to preview uncommitted changes

But even for testing, dry-run is safer:
```bash
./bootstrap.sh --extra-vars "force_config=true" --check --diff
```

### Handling Conflicts
- **stow --adopt**: Moves local files into dotfiles (local becomes source of truth)
- **force_config=true**: Backs up local files, dotfiles become source of truth
- **Normal mode**: Attempts to merge, adopts conflicts automatically

## Platform Detection

The playbook automatically detects your platform:
- **macOS**: Uses Homebrew for package management
- **Linux**: Uses apt for package management (Debian/Ubuntu)

## Updating

To update all packages and dotfiles:

```bash
cd ~/dotfiles
git pull origin main
./bootstrap.sh
```

To selectively upgrade specific packages, edit `playbook.yml` and change `state: present` to `state: latest` for desired packages.

## Dependencies

### Installed by Bootstrap
- **uv**: Python package manager (installed via curl)
- **Ansible**: Configuration management (installed via uv)

### Installed by Ansible Playbook

See "What's Included" section above for complete package list with platform availability.

## Troubleshooting

### Linux: Ghostty doesn't open with Ctrl+Alt+T
```bash
# Check default terminal
update-alternatives --query x-terminal-emulator

# Set Ghostty as default
sudo update-alternatives --set x-terminal-emulator /usr/bin/ghostty
```

### Linux: keyd not working
```bash
# Check service status
sudo systemctl status keyd

# Restart service
sudo systemctl restart keyd

# View logs
sudo journalctl -u keyd -f
```

### macOS: Homebrew not in PATH (Apple Silicon)
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Python/uv issues
```bash
# Check uv installation
uv --version

# Check Ansible installation via uv
uv tool list

# Reinstall Ansible
uv tool uninstall ansible-core
uv tool install ansible-core
```

### Sudo password prompt (Linux)

By default, the bootstrap script will prompt for your sudo password on Linux (needed for `apt` operations). If you want to avoid typing your password every time:

**Option 1: Configure passwordless sudo for specific commands** (Recommended)
```bash
sudo visudo
# Add this line (replace 'yourusername' with your actual username):
yourusername ALL=(ALL) NOPASSWD: /usr/bin/apt, /usr/bin/dpkg, /usr/bin/systemctl
```

**Option 2: Skip password prompt** (Not recommended - less secure)
Edit `bootstrap.sh` and remove the `-K` flag from the `ansible-playbook` command.

**Option 3: Store sudo credentials temporarily**
```bash
sudo -v  # Validates and caches credentials for 5 minutes
./bootstrap.sh --extra-vars "force_config=true"
```

## Structure

```
dotfiles/
├── bootstrap.sh              # Main installation script
├── playbook.yml             # Ansible configuration
├── inventory.yml            # Ansible inventory (localhost)
├── requirements.yml         # Ansible Galaxy collections
├── README.md                # This file
├── zsh/                     # Zsh configuration
├── git/                     # Git configuration
├── nvim/                    # Neovim configuration
├── starship/                # Starship prompt
├── tmux/                    # Tmux configuration
├── ghostty/                 # Ghostty terminal
├── @macos/                  # macOS-specific configs
├── aerospace/               # AeroSpace window manager (macOS)
├── karabiner/               # Karabiner keyboard config (macOS)
└── keyd/                    # keyd keyboard config (Linux)
```

## Credits

- [GNU Stow](https://www.gnu.org/software/stow/) for dotfiles management
- [Ansible](https://www.ansible.com/) for configuration management
- [uv](https://github.com/astral-sh/uv) for Python/tool management
- [LazyVim](https://www.lazyvim.org/) for Neovim configuration
- [Starship](https://starship.rs/) for the cross-shell prompt
- [Tokyo Night](https://github.com/folke/tokyonight.nvim) color scheme
