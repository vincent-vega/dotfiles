# Dotfiles

Personal configuration files for bash, vim, neovim, tmux, alacritty, and ranger.

## Prerequisites

- Git
- Make
- Vim/Neovim (optional, for vim configurations)
- Tmux (optional, for tmux configuration)
- Alacritty (optional, for terminal configuration)
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
make conf        # Install tmux, alacritty, and ranger configurations only
```

## Included Vim Plugins

The following vim plugins are included as submodules:

- [delimitMate](https://github.com/Raimondi/delimitMate) - Auto-completion for quotes, parens, brackets
- [jedi-vim](https://github.com/davidhalter/jedi-vim) - Python autocompletion
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

To remove all symlinks created by this dotfiles setup:

```bash
make clean
```

Note: This will only remove symlinks, not the actual dotfiles repository or any backup files created during installation.

## Platform-Specific Notes

### macOS

On macOS (Darwin), the Alacritty configuration will use `alacritty-macos.toml` instead of the standard `alacritty.toml`.

### Ranger Icons

The Ranger configuration uses the `ranger_devicons` plugin to display file icons. This requires a Nerd Font to be installed for the icons to display correctly.

**Installing Nerd Fonts on macOS:**

```bash
# Using Homebrew (recommended)
brew install font-hack-nerd-font

# Or manually download and install
# Download from: https://github.com/ryanoasis/nerd-fonts/releases
# Move .ttf files to ~/Library/Fonts/
```

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
family = "SauceCodePro Nerd Font"  # or "Hack Nerd Font" if using Hack
```

### Backups

The installation process will automatically create backups if existing configurations are found for:
- Neovim configuration (backed up with random suffix)
- Ranger configuration (backed up with random suffix)

## Directory Structure

```
dotfiles/
├── bash/           # Bash configuration files
├── bin/            # Custom scripts
├── conf/           # Configuration files (tmux, alacritty, ranger)
├── conky/          # Conky configuration
├── vim/            # Vim and Neovim configuration
│   └── pack/       # Vim plugins (submodules)
└── makefile        # Installation script
```
