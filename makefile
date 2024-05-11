dotfiles_dir=${HOME}/dotfiles
bash_dir=${dotfiles_dir}/bash
vim_dir=${dotfiles_dir}/vim
conf_dir=${dotfiles_dir}/conf
OS := $(shell uname)

.PHONY: all bash clean conf neovim vim vimplugins

all: bash conf neovim vim vimplugins
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
	@if [ -e "${HOME}/.config/nvim" ]; then \
		echo Existing Neovim configuration found, creating backup...; \
		mv "${HOME}/.config/nvim" "${HOME}/.config/nvim-$(shell mktemp -u XXXXX)-backup"; \
	fi
	@ln -sf "${vim_dir}/nvim" "${HOME}/.config/nvim"

conf: ${conf_dir}/tmux.conf ${conf_dir}/alacritty.toml ${conf_dir}/alacritty-macos.toml
	@[ -s ${HOME}/.tmux.conf ] || ln -sf "${conf_dir}/tmux.conf" "${HOME}/.tmux.conf"
ifeq ($(OS), Darwin)
	@[ -s ${HOME}/.alacritty-macos.toml ] || ln -sf "${conf_dir}/alacritty-macos.toml" "${HOME}/.alacritty.toml"
else
	@[ -s ${HOME}/.alacritty.toml ] || ln -sf "${conf_dir}/alacritty.toml" "${HOME}/.alacritty.toml"
endif
	@if [ -e "${HOME}/.config/ranger" ]; then \
		echo Existing Ranger configuration found, creating backup...; \
		mv "${HOME}/.config/ranger" "${HOME}/.config/ranger-$(shell mktemp -u XXXXX)-backup"; \
	fi
	@ln -s "${conf_dir}/ranger" "${HOME}/.config/ranger"

clean:
	@ ! [ -e "${HOME}/.alacritty.toml" ]       || rm -f "${HOME}/.alacritty.toml"
	@ ! [ -e "${HOME}/.bash_profile" ]         || rm -f "${HOME}/.bash_profile"
	@ ! [ -e "${HOME}/.bashrc" ]               || rm -f "${HOME}/.bashrc"
	@ ! [ -e "${HOME}/.config/nvim/init.vim" ] || rm -f "${HOME}/.config/nvim/init.vim"
	@ ! [ -e "${HOME}/.gvimrc" ]               || rm -f "${HOME}/.gvimrc"
	@ ! [ -e "${HOME}/.ideavimrc" ]            || rm -f "${HOME}/.ideavimrc"
	@ ! [ -e "${HOME}/.inputrc" ]              || rm -f "${HOME}/.inputrc"
	@ ! [ -e "${HOME}/.tmux.conf" ]            || rm -f "${HOME}/.tmux.conf"
	@ ! [ -e "${HOME}/.vim" ]                  || rm -f "${HOME}/.vim"
	@ ! [ -e "${HOME}/.vimrc" ]                || rm -f "${HOME}/.vimrc"
	@ ! [ -e "${HOME}/.vrapperrc" ]            || rm -f "${HOME}/.vrapperrc"
