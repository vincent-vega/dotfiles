bash_dir=${HOME}/dotfiles/bash
conky_dir=${HOME}/dotfiles/conky
dotfiles_dir=${HOME}/dotfiles
vim_dir=${HOME}/dotfiles/vim

.PHONY: clean all bash vim others

all: bash vim others
	@echo "Complete!"

bash: ${bash_dir}/bash_profile ${bash_dir}/bashrc ${bash_dir}/inputrc
	@[ -e ${HOME}/.bash_profile ] || ln -s ${bash_dir}/bash_profile ${HOME}/.bash_profile;
	@[ -e ${HOME}/.bashrc ]       || ln -s ${bash_dir}/bashrc       ${HOME}/.bashrc;
	@[ -e ${HOME}/.inputrc ]      || ln -s ${bash_dir}/inputrc      ${HOME}/.inputrc;

vim: ${vim_dir} ${vim_dir}/gvimrc ${vim_dir}/vimrc ${vim_dir}/vrapperrc
	@[ -e ${HOME}/.vim ]       || ln -s ${vim_dir}           ${HOME}/.vim;
	@[ -e ${HOME}/.gvimrc ]    || ln -s ${vim_dir}/gvimrc    ${HOME}/.gvimrc;
	@[ -e ${HOME}/.vimrc ]     || ln -s ${vim_dir}/vimrc     ${HOME}/.vimrc;
	@[ -e ${HOME}/.vrapperrc ] || ln -s ${vim_dir}/vrapperrc ${HOME}/.vrapperrc;

others: ${dotfiles_dir}/tmux.conf ${conky_dir}/conkyrc
	@[ -e ${HOME}/.conkyrc ]   || ln -s ${conky_dir}/conkyrc      ${HOME}/.conkyrc;
	@[ -e ${HOME}/.tmux.conf ] || ln -s ${dotfiles_dir}/tmux.conf ${HOME}/.tmux.conf;

clean:
	@[ -L ${HOME}/.bash_profile ] && rm -f ${HOME}/.bash_profile;
	@[ -L ${HOME}/.bashrc ]       && rm -f ${HOME}/.bashrc;
	@[ -L ${HOME}/.conkyrc ]      && rm -f ${HOME}/.conkyrc;
	@[ -L ${HOME}/.gvimrc ]       && rm -f ${HOME}/.gvimrc;
	@[ -L ${HOME}/.inputrc ]      && rm -f ${HOME}/.inputrc;
	@[ -L ${HOME}/.tmux.conf ]    && rm -f ${HOME}/.tmux.conf;
	@[ -L ${HOME}/.vim ]          && rm -f ${HOME}/.vim;
	@[ -L ${HOME}/.vimrc ]        && rm -f ${HOME}/.vimrc;
	@[ -L ${HOME}/.vrapperrc ]    && rm -f ${HOME}/.vrapperrc;
