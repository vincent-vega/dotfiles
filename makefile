dotfiles_dir=${HOME}/dotfiles
bash_dir=${dotfiles_dir}/bash
vim_dir=${dotfiles_dir}/vim
conf_dir=${dotfiles_dir}/conf
OS := $(shell uname)

.PHONY: clean all bash vim conf

all: bash vim conf
	@echo "Complete!"

bash: ${bash_dir}/bash_profile ${bash_dir}/bashrc ${bash_dir}/inputrc
	@[ -e ${HOME}/.bash_profile ] || ln -sf ${bash_dir}/bash_profile ${HOME}/.bash_profile
	@[ -e ${HOME}/.bashrc ]       || ln -sf ${bash_dir}/bashrc       ${HOME}/.bashrc
	@[ -e ${HOME}/.inputrc ]      || ln -sf ${bash_dir}/inputrc      ${HOME}/.inputrc

vim: ${vim_dir} ${vim_dir}/gvimrc ${vim_dir}/vimrc ${vim_dir}/vrapperrc
	@[ -e ${HOME}/.gvimrc ]    || ln -sf ${vim_dir}/gvimrc    ${HOME}/.gvimrc
	@[ -e ${HOME}/.ideavimrc ] || ln -sf ${vim_dir}/ideavimrc ${HOME}/.ideavimrc
	@[ -e ${HOME}/.vim ]       || ln -sf ${vim_dir}           ${HOME}/.vim
	@[ -e ${HOME}/.vimrc ]     || ln -sf ${vim_dir}/vimrc     ${HOME}/.vimrc
	@[ -e ${HOME}/.vrapperrc ] || ln -sf ${vim_dir}/vrapperrc ${HOME}/.vrapperrc

conf: ${conf_dir}/tmux.conf ${conf_dir}/alacritty.toml ${conf_dir}/alacritty-macos.toml
	@[ -s ${HOME}/.tmux.conf ] || ln -sf ${conf_dir}/tmux.conf ${HOME}/.tmux.conf
ifeq ($(OS), Darwin)
	@[ -s ${HOME}/.alacritty-macos.toml ] || ln -sf ${conf_dir}/alacritty-macos.toml ${HOME}/.alacritty.toml
else
	@[ -s ${HOME}/.alacritty.toml ] || ln -sf ${conf_dir}/alacritty.toml ${HOME}/.alacritty.toml
endif
	@if [ -e "${HOME}/.config/ranger" ]; then \
		echo existing ranger configuration found, creating backup...; \
		mv ${HOME}/.config/ranger  "${HOME}/.config/ranger-$(shell mktemp -u XXXXX)-backup"; \
	fi
	@ln -s ${conf_dir}/ranger ${HOME}/.config/ranger

clean:
	@ ! [ -e ${HOME}/.alacritty.toml ] || rm -f ${HOME}/.alacritty.toml
	@ ! [ -e ${HOME}/.bash_profile ]  || rm -f ${HOME}/.bash_profile
	@ ! [ -e ${HOME}/.bashrc ]        || rm -f ${HOME}/.bashrc
	@ ! [ -e ${HOME}/.gvimrc ]        || rm -f ${HOME}/.gvimrc
	@ ! [ -e ${HOME}/.ideavimrc ]     || rm -f ${HOME}/.ideavimrc
	@ ! [ -e ${HOME}/.inputrc ]       || rm -f ${HOME}/.inputrc
	@ ! [ -e ${HOME}/.tmux.conf ]     || rm -f ${HOME}/.tmux.conf
	@ ! [ -e ${HOME}/.vim ]           || rm -f ${HOME}/.vim
	@ ! [ -e ${HOME}/.vimrc ]         || rm -f ${HOME}/.vimrc
	@ ! [ -e ${HOME}/.vrapperrc ]     || rm -f ${HOME}/.vrapperrc
