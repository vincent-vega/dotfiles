bash_dir=${HOME}/dotfiles/bash
conky_dir=${HOME}/dotfiles/conky
dotfiles_dir=${HOME}/dotfiles
vim_dir=${HOME}/dotfiles/vim

.PHONY: clean all bash vim others

all: bash vim others
	@echo "Complete!"

bash: ${bash_dir}/bash_profile ${bash_dir}/bashrc ${bash_dir}/inputrc
	@[ -L ${HOME}/.bash_profile ] || ln -s ${bash_dir}/bash_profile ${HOME}/.bash_profile;
	@[ -L ${HOME}/.bashrc ]       || ln -s ${bash_dir}/bashrc       ${HOME}/.bashrc;
	@[ -L ${HOME}/.inputrc ]      || ln -s ${bash_dir}/inputrc      ${HOME}/.inputrc;

vim: ${vim_dir} ${vim_dir}/gvimrc ${vim_dir}/vimrc ${vim_dir}/vrapperrc
	@[ -L ${HOME}/.vim ]       || ln -s ${vim_dir}           ${HOME}/.vim;
	@[ -L ${HOME}/.gvimrc ]    || ln -s ${vim_dir}/gvimrc    ${HOME}/.gvimrc;
	@[ -L ${HOME}/.vimrc ]     || ln -s ${vim_dir}/vimrc     ${HOME}/.vimrc;
	@[ -L ${HOME}/.vrapperrc ] || ln -s ${vim_dir}/vrapperrc ${HOME}/.vrapperrc;

others: ${dotfiles_dir}/tmux.conf ${conky_dir}/conkyrc
	@[ -L ${HOME}/.conkyrc ]   || ln -s ${conky_dir}/conkyrc      ${HOME}/.conkyrc;
	@[ -L ${HOME}/.tmux.conf ] || ln -s ${dotfiles_dir}/tmux.conf ${HOME}/.tmux.conf;

clean:
	@rm -f ${HOME}/.bash_profile;
	@rm -f ${HOME}/.bashrc;
	@rm -f ${HOME}/.conkyrc;
	@rm -f ${HOME}/.gvimrc;
	@rm -f ${HOME}/.inputrc;
	@rm -f ${HOME}/.tmux.conf;
	@rm -f ${HOME}/.vim;
	@rm -f ${HOME}/.vimrc;
	@rm -f ${HOME}/.vrapperrc;
