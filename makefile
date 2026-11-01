dotfiles    := $(HOME)/dotfiles
neovide_dir := $(HOME)/.config/neovide
OS          := $(shell uname)

# Links are "source:destination" pairs, relative to $(dotfiles) and $(HOME).
# Plain links never touch an existing non-empty file or directory (empty files get replaced).
bash_links       := bash/bash_profile:.bash_profile bash/bashrc:.bashrc bash/inputrc:.inputrc
vim_links        := vim:.vim vim/vimrc:.vimrc vim/gvimrc:.gvimrc
vimplugins_links := vim/ideavimrc:.ideavimrc vim/vrapperrc:.vrapperrc
bin_links        := bin/cfr.sh:.local/bin/cfr bin/clearhistorydups.py:.local/bin/clearhistorydups
conf_links       := conf/tmux.conf:.tmux.conf
ifeq ($(OS),Darwin)
conf_links       += conf/alacritty-macos.toml:.alacritty.toml
else
conf_links       += conf/alacritty.toml:.alacritty.toml
endif

# Forced links replace whatever is at the destination, backing it up first.
neovim_forced    := vim/nvim:.config/nvim
conf_forced      := conf/ranger:.config/ranger

all_links := $(bash_links) $(vim_links) $(vimplugins_links) $(bin_links) $(conf_links) \
             $(neovim_forced) $(conf_forced)

src        = $(dotfiles)/$(firstword $(subst :, ,$1))
dst        = $(HOME)/$(lastword $(subst :, ,$1))
backup     = if [ -e "$1" ] || [ -L "$1" ]; then echo "Backing up $1"; mv "$1" "$1-$$(mktemp -u XXXXX)-backup"; fi
link       = $(foreach p,$1,mkdir -p "$(dir $(call dst,$p))"; \
               [ -s "$(call dst,$p)" ] || [ -d "$(call dst,$p)" ] || ln -sf "$(call src,$p)" "$(call dst,$p)";)
force_link = $(foreach p,$1,[ "$$(readlink "$(call dst,$p)" 2>/dev/null)" = "$(call src,$p)" ] || { \
               $(call backup,$(call dst,$p)); mkdir -p "$(dir $(call dst,$p))"; ln -s "$(call src,$p)" "$(call dst,$p)"; };)
srcs       = $(foreach p,$1,$(call src,$p))

.PHONY: all bash bin clean conf neovim vim vimplugins

all: bash bin conf neovim vim vimplugins
	@echo "Complete!"

# Sources are prerequisites, so make stops before touching anything if one is missing.
bash:       $(call srcs,$(bash_links))
bin:        $(call srcs,$(bin_links))
vim:        $(call srcs,$(vim_links))
vimplugins: $(call srcs,$(vimplugins_links))

bash bin vim vimplugins:
	@$(call link,$($@_links))

neovim: $(call srcs,$(neovim_forced))
	@$(call force_link,$(neovim_forced))

conf: $(call srcs,$(conf_links) $(conf_forced)) $(dotfiles)/conf/neovide/config.toml
	@$(call link,$(conf_links))
	@$(call force_link,$(conf_forced))
	@gen="$$(sed 's|@HOME@|$(HOME)|g' "$(dotfiles)/conf/neovide/config.toml")"; \
	if [ -L "$(neovide_dir)" ] || [ "$$gen" != "$$(cat "$(neovide_dir)/config.toml" 2>/dev/null)" ]; then \
		$(call backup,$(neovide_dir)); \
		mkdir -p "$(neovide_dir)" && printf '%s\n' "$$gen" > "$(neovide_dir)/config.toml"; \
	fi

clean:
	@$(foreach p,$(all_links),[ ! -L "$(call dst,$p)" ] || rm -f "$(call dst,$p)";)
	@rm -rf "$(neovide_dir)"
