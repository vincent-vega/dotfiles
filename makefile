bash_dir=${HOME}/dotfiles/bash
dotfiles_dir=${HOME}/dotfiles
vim_dir=${HOME}/dotfiles/vim

.PHONY: clean all bash vim others

all: bash vim others
	@echo "Complete!"

bash: ${bash_dir}/bash_profile ${bash_dir}/bashrc ${bash_dir}/inputrc
	@[ -e ${HOME}/.bash_profile ] || ln -sf ${bash_dir}/bash_profile ${HOME}/.bash_profile;
	@[ -e ${HOME}/.bashrc ]       || ln -sf ${bash_dir}/bashrc       ${HOME}/.bashrc;
	@[ -e ${HOME}/.inputrc ]      || ln -sf ${bash_dir}/inputrc      ${HOME}/.inputrc;

vim: ${vim_dir} ${vim_dir}/gvimrc ${vim_dir}/vimrc ${vim_dir}/vrapperrc
	@[ -e ${HOME}/.vim ]       || ln -sf ${vim_dir}           ${HOME}/.vim;
	@[ -e ${HOME}/.gvimrc ]    || ln -sf ${vim_dir}/gvimrc    ${HOME}/.gvimrc;
	@[ -e ${HOME}/.ideavimrc ] || ln -sf ${vim_dir}/ideavimrc ${HOME}/.ideavimrc;
	@[ -e ${HOME}/.vimrc ]     || ln -sf ${vim_dir}/vimrc     ${HOME}/.vimrc;
	@[ -e ${HOME}/.vrapperrc ] || ln -sf ${vim_dir}/vrapperrc ${HOME}/.vrapperrc;

others: ${dotfiles_dir}/tmux.conf
	@[ -s ${HOME}/.tmux.conf ] || ln -sf ${dotfiles_dir}/tmux.conf ${HOME}/.tmux.conf;

clean:
	@[ -L ${HOME}/.bash_profile ] && rm -f ${HOME}/.bash_profile;
	@[ -L ${HOME}/.bashrc ]       && rm -f ${HOME}/.bashrc;
	@[ -L ${HOME}/.conkyrc ]      && rm -f ${HOME}/.conkyrc;
	@[ -L ${HOME}/.gvimrc ]       && rm -f ${HOME}/.gvimrc;
	@[ -L ${HOME}/.ideavimrc ]    && rm -f ${HOME}/.ideavimrc;
	@[ -L ${HOME}/.inputrc ]      && rm -f ${HOME}/.inputrc;
	@[ -L ${HOME}/.tmux.conf ]    && rm -f ${HOME}/.tmux.conf;
	@[ -L ${HOME}/.vim ]          && rm -f ${HOME}/.vim;
	@[ -L ${HOME}/.vimrc ]        && rm -f ${HOME}/.vimrc;
	@[ -L ${HOME}/.vrapperrc ]    && rm -f ${HOME}/.vrapperrc;
