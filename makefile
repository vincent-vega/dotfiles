dotfiles_dir=${HOME}/dotfiles
bash_dir=${dotfiles_dir}/bash
vim_dir=${dotfiles_dir}/vim
conf_dir=${dotfiles_dir}/conf
bin_dir=${dotfiles_dir}/bin
local_bin=${HOME}/.local/bin
OS := $(shell uname)

.PHONY: all bash bin clean conf neovim vim vimplugins

all: bash bin conf neovim vim vimplugins
	@echo "Complete!"

bash: ${bash_dir}/bash_profile ${bash_dir}/bashrc ${bash_dir}/inputrc
	@[ -e "${HOME}/.bash_profile" ] || ln -sf "${bash_dir}/bash_profile" "${HOME}/.bash_profile"
	@[ -e "${HOME}/.bashrc" ]       || ln -sf "${bash_dir}/bashrc"       "${HOME}/.bashrc"
	@[ -e "${HOME}/.inputrc" ]      || ln -sf "${bash_dir}/inputrc"      "${HOME}/.inputrc"

vim: ${vim_dir} ${vim_dir}/gvimrc ${vim_dir}/vimrc
	@[ -e "${HOME}/.gvimrc" ] || ln -sf "${vim_dir}/gvimrc" "${HOME}/.gvimrc"
	@[ -e "${HOME}/.vim" ]    || ln -sf "${vim_dir}"        "${HOME}/.vim"
	@[ -e "${HOME}/.vimrc" ]  || ln -sf "${vim_dir}/vimrc"  "${HOME}/.vimrc"

vimplugins: ${vim_dir}/ideavimrc ${vim_dir}/vrapperrc
	@[ -e "${HOME}/.ideavimrc" ] || ln -sf "${vim_dir}/ideavimrc" "${HOME}/.ideavimrc"
	@[ -e "${HOME}/.vrapperrc" ] || ln -sf "${vim_dir}/vrapperrc" "${HOME}/.vrapperrc"

neovim: ${vim_dir}/nvim
	@target="${HOME}/.config/nvim"; src="${vim_dir}/nvim"; \
	if [ "$$(readlink "$$target" 2>/dev/null)" = "$$src" ]; then : ; else \
		if [ -e "$$target" ] || [ -L "$$target" ]; then \
			echo Existing Neovim configuration found, creating backup...; \
			mv "$$target" "$$target-$$(mktemp -u XXXXX)-backup"; \
		fi; \
		ln -s "$$src" "$$target"; \
	fi

conf: ${conf_dir}/tmux.conf ${conf_dir}/alacritty.toml ${conf_dir}/alacritty-macos.toml ${conf_dir}/neovide/config.toml
	@[ -s ${HOME}/.tmux.conf ] || ln -sf "${conf_dir}/tmux.conf" "${HOME}/.tmux.conf"
ifeq ($(OS), Darwin)
	@[ -s ${HOME}/.alacritty-macos.toml ] || ln -sf "${conf_dir}/alacritty-macos.toml" "${HOME}/.alacritty.toml"
else
	@[ -s ${HOME}/.alacritty.toml ] || ln -sf "${conf_dir}/alacritty.toml" "${HOME}/.alacritty.toml"
endif
	@target="${HOME}/.config/ranger"; src="${conf_dir}/ranger"; \
	if [ "$$(readlink "$$target" 2>/dev/null)" = "$$src" ]; then : ; else \
		if [ -e "$$target" ] || [ -L "$$target" ]; then \
			echo Existing Ranger configuration found, creating backup...; \
			mv "$$target" "$$target-$$(mktemp -u XXXXX)-backup"; \
		fi; \
		ln -s "$$src" "$$target"; \
	fi
	@target="${HOME}/.config/neovide"; src="${conf_dir}/neovide/config.toml"; \
	gen="$$(sed "s|@HOME@|${HOME}|g" "$$src")"; \
	if ! [ -L "$$target" ] && [ -f "$$target/config.toml" ] && [ "$$gen" = "$$(cat "$$target/config.toml")" ]; then : ; else \
		if [ -e "$$target" ] || [ -L "$$target" ]; then \
			echo Existing Neovide configuration found, creating backup...; \
			mv "$$target" "$$target-$$(mktemp -u XXXXX)-backup"; \
		fi; \
		mkdir -p "$$target"; \
		printf '%s\n' "$$gen" > "$$target/config.toml"; \
	fi

bin: ${bin_dir}/cfr.sh ${bin_dir}/clearhistorydups.py
	@mkdir -p "${local_bin}"
	@[ -e "${local_bin}/cfr" ]              || ln -sf "${bin_dir}/cfr.sh"              "${local_bin}/cfr"
	@[ -e "${local_bin}/clearhistorydups" ] || ln -sf "${bin_dir}/clearhistorydups.py" "${local_bin}/clearhistorydups"

clean:
	@ ! [ -h "${local_bin}/cfr" ]              || rm -f "${local_bin}/cfr"
	@ ! [ -h "${local_bin}/clearhistorydups" ] || rm -f "${local_bin}/clearhistorydups"
	@ ! [ -h "${HOME}/.alacritty.toml" ]       || rm -f "${HOME}/.alacritty.toml"
	@ ! [ -h "${HOME}/.bash_profile" ]         || rm -f "${HOME}/.bash_profile"
	@ ! [ -h "${HOME}/.bashrc" ]               || rm -f "${HOME}/.bashrc"
	@ ! [ -e "${HOME}/.config/neovide" ]       || rm -rf "${HOME}/.config/neovide"
	@ ! [ -h "${HOME}/.config/nvim" ]          || rm -f "${HOME}/.config/nvim"
	@ ! [ -h "${HOME}/.config/ranger" ]        || rm -f "${HOME}/.config/ranger"
	@ ! [ -h "${HOME}/.gvimrc" ]               || rm -f "${HOME}/.gvimrc"
	@ ! [ -h "${HOME}/.ideavimrc" ]            || rm -f "${HOME}/.ideavimrc"
	@ ! [ -h "${HOME}/.inputrc" ]              || rm -f "${HOME}/.inputrc"
	@ ! [ -h "${HOME}/.tmux.conf" ]            || rm -f "${HOME}/.tmux.conf"
	@ ! [ -h "${HOME}/.vim" ]                  || rm -f "${HOME}/.vim"
	@ ! [ -h "${HOME}/.vimrc" ]                || rm -f "${HOME}/.vimrc"
	@ ! [ -h "${HOME}/.vrapperrc" ]            || rm -f "${HOME}/.vrapperrc"
