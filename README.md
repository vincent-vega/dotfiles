# Dotfiles

Personal configuration files for bash, vim, neovim, tmux, alacritty, and ranger.

## Prerequisites

- Git
- Make
- Vim/Neovim (optional, for vim configurations)
- Tmux (optional, for tmux configuration)
- Alacritty (optional, for terminal configuration)
- Neovide (optional, for the Neovim GUI configuration)
- Ranger (optional, for file manager configuration)

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/vincent-vega/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Initialize Submodules

This project uses git submodules for vim plugins and ranger plugins. Initialize and download them with:

```bash
git submodule init
git submodule update
```

Alternatively, you can use the recursive option when cloning:

```bash
git clone --recursive https://github.com/vincent-vega/dotfiles.git ~/dotfiles
```

### 3. Install Configurations

Run the makefile to create symlinks for all configurations:

```bash
make all
```

This will set up:
- Bash configuration files (.bash_profile, .bashrc, .inputrc)
- Vim configuration files (.vim, .vimrc, .gvimrc)
- Neovim configuration (.config/nvim)
- Neovide configuration (.config/neovide)
- Vim plugin configurations (.ideavimrc, .vrapperrc)
- Tmux configuration (.tmux.conf)
- Alacritty configuration (.alacritty.toml)
- Ranger configuration (.config/ranger)

### Individual Component Installation

You can also install individual components:

```bash
make bash        # Install bash configuration only
make vim         # Install vim configuration only
make vimplugins  # Install vim plugin configurations only
make neovim      # Install neovim configuration only
make conf        # Install tmux, alacritty, neovide and ranger configurations only
```

## Included Vim Plugins

The following vim plugins are included as submodules:

- [delimitMate](https://github.com/Raimondi/delimitMate) - Auto-completion for quotes, parens, brackets
- [nerdcommenter](https://github.com/preservim/nerdcommenter) - Comment functions
- [nerdtree](https://github.com/preservim/nerdtree) - File system explorer
- [tagbar](https://github.com/majutsushi/tagbar) - Display tags in a window
- [ale](https://github.com/dense-analysis/ale) - Asynchronous Lint Engine
- [lightline.vim](https://github.com/itchyny/lightline.vim) - Light and configurable statusline
- [undotree](https://github.com/mbbill/undotree) - Undo history visualizer
- [vim-startify](https://github.com/mhinz/vim-startify) - Start screen for Vim

## Updating Submodules

To update all submodules to their latest versions:

```bash
git submodule update --remote --merge
```

## Uninstallation

To remove the symlinks created by this dotfiles setup and the generated Neovide config:

```bash
make clean
```

Note: This will not touch the dotfiles repository or any backup files created during installation.

## Platform-Specific Notes

### macOS

On macOS (Darwin), the Alacritty configuration will use `alacritty-macos.toml` instead of the standard `alacritty.toml`.

The macOS setup expects [MacPorts](https://www.macports.org/install.php) in `/opt/local`. `alacritty-macos.toml` launches `/opt/local/bin/bash` as its shell because the system bash is stuck at 3.2, so Alacritty will not start without the `bash` port. The bash configuration also picks up git prompt, bash-completion and other tools from `/opt/local` when present. The full list of ports in use is in `conf/macports_packages.txt`; install them with:

```bash
xargs sudo port install < conf/macports_packages.txt
```

### Neovide

`make conf` generates `~/.config/neovide/config.toml` from `conf/neovide/config.toml`, substituting `@HOME@` with the current `$HOME`. Neovide does not expand `~` or environment variables in this file, so the absolute path to the `nvim-gui` wrapper is filled in per user/OS at install time.

### Ranger Icons

The Ranger configuration uses the `ranger_devicons` plugin to display file icons. This requires a Nerd Font to be installed for the icons to display correctly.

**Installing Nerd Fonts on macOS:**

No package manager needed: macOS loads any font dropped into `~/Library/Fonts` immediately, with no Font Book step and no restart. The Alacritty config in this repo uses Hack:

```bash
# Download the Hack Nerd Font and install it for the current user
cd "$(mktemp -d)"
curl -fsSLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
unzip -q Hack.zip -d ~/Library/Fonts
ls ~/Library/Fonts | grep -c HackNerdFont   # expect 12
```

Other fonts are listed at https://www.nerdfonts.com/font-downloads. To upgrade, run the same commands again; to remove, delete the `HackNerdFont*.ttf` files. Open a new Alacritty window afterwards.

**Installing Nerd Fonts on Linux:**

```bash
# Create fonts directory if it doesn't exist
mkdir -p ~/.local/share/fonts

# Download a Nerd Font (e.g., Source Code Pro)
cd ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/SourceCodePro.zip

# Extract the font
unzip SourceCodePro.zip
rm SourceCodePro.zip

# Update font cache
fc-cache -fv
```

**Terminal Configuration:**

Most terminals will automatically use the installed Nerd Font and icons should display correctly. If icons still appear as squares, you may need to configure your terminal to use the Nerd Font explicitly. For Alacritty, add this to `~/.config/alacritty/alacritty.toml`:

```toml
[font.normal]
family = "Hack Nerd Font Mono"  # or "SauceCodePro Nerd Font" if using Source Code Pro
```

### Backups

The installation process will automatically create backups if existing configurations are found for:
- Neovim configuration (backed up with random suffix)
- Ranger configuration (backed up with random suffix)
- Neovide configuration (backed up with random suffix, only if it differs from the generated one)

## Directory Structure

```
dotfiles/
├── bash/           # Bash configuration files
├── bin/            # Custom scripts
├── conf/           # Configuration files (tmux, alacritty, ranger, neovide, ...)
├── conky/          # Conky configuration
├── vim/            # Vim and Neovim configuration
│   └── pack/       # Vim plugins (submodules)
└── makefile        # Installation script
```
