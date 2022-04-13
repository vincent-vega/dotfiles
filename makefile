dotfiles_dir=${HOME}/dotfiles
bash_dir=${dotfiles_dir}/bash
vim_dir=${dotfiles_dir}/vim

.PHONY: clean all bash vim others

all: bash vim others
	@echo "Complete!"

bash: ${bash_dir}/bash_profile ${bash_dir}/bashrc ${bash_dir}/inputrc
	@[ -e ${HOME}/.bash_profile ] || ln -sf ${bash_dir}/bash_profile ${HOME}/.bash_profile
	@[ -e ${HOME}/.bashrc ]       || ln -sf ${bash_dir}/bashrc       ${HOME}/.bashrc
	@[ -e ${HOME}/.inputrc ]      || ln -sf ${bash_dir}/inputrc      ${HOME}/.inputrc

vim: ${vim_dir} ${vim_dir}/gvimrc ${vim_dir}/vimrc ${vim_dir}/vrapperrc
	@[ -e ${HOME}/.vim ]       || ln -sf ${vim_dir}           ${HOME}/.vim
	@[ -e ${HOME}/.gvimrc ]    || ln -sf ${vim_dir}/gvimrc    ${HOME}/.gvimrc
	@[ -e ${HOME}/.ideavimrc ] || ln -sf ${vim_dir}/ideavimrc ${HOME}/.ideavimrc
	@[ -e ${HOME}/.vimrc ]     || ln -sf ${vim_dir}/vimrc     ${HOME}/.vimrc
	@[ -e ${HOME}/.vrapperrc ] || ln -sf ${vim_dir}/vrapperrc ${HOME}/.vrapperrc

others: ${dotfiles_dir}/tmux.conf
	@[ -s ${HOME}/.tmux.conf ] || ln -sf ${dotfiles_dir}/tmux.conf ${HOME}/.tmux.conf

clean:
	@ ! [ -e ${HOME}/.bash_profile ] || rm -f ${HOME}/.bash_profile
	@ ! [ -e ${HOME}/.bashrc ]       || rm -f ${HOME}/.bashrc
	@ ! [ -e ${HOME}/.gvimrc ]       || rm -f ${HOME}/.gvimrc
	@ ! [ -e ${HOME}/.ideavimrc ]    || rm -f ${HOME}/.ideavimrc
	@ ! [ -e ${HOME}/.inputrc ]      || rm -f ${HOME}/.inputrc
	@ ! [ -e ${HOME}/.tmux.conf ]    || rm -f ${HOME}/.tmux.conf
	@ ! [ -e ${HOME}/.vim ]          || rm -f ${HOME}/.vim
	@ ! [ -e ${HOME}/.vimrc ]        || rm -f ${HOME}/.vimrc
	@ ! [ -e ${HOME}/.vrapperrc ]    || rm -f ${HOME}/.vrapperrc
