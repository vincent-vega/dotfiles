bash_dir=${HOME}/dotfiles/bash
conky_dir=${HOME}/dotfiles/conky
dotfiles_dir=${HOME}/dotfiles
vim_dir=${HOME}/dotfiles/vim

.PHONY: clean

link: bash vim others
	@echo "Link target complete!";

bash: clean ${bash_dir}/bash_profile ${bash_dir}/bashrc ${bash_dir}/inputrc
	ln -s ${bash_dir}/bash_profile ${HOME}/.bash_profile;
	ln -s ${bash_dir}/bashrc       ${HOME}/.bashrc;
	ln -s ${bash_dir}/inputrc      ${HOME}/.inputrc;

vim: clean ${vim_dir} ${vim_dir}/gvimrc ${vim_dir}/vimrc ${vim_dir}/vrapperrc
	ln -s ${vim_dir}           ${HOME}/.vim;
	ln -s ${vim_dir}/gvimrc    ${HOME}/.gvimrc;
	ln -s ${vim_dir}/vimrc     ${HOME}/.vimrc;
	ln -s ${vim_dir}/vrapperrc ${HOME}/.vrapperrc;

others: clean ${dotfiles_dir}/tmux.conf ${conky_dir} ${conky_dir}/conkyrc
	ln -s ${conky_dir}/conkyrc      ${HOME}/.conkyrc;
	ln -s ${dotfiles_dir}/tmux.conf ${HOME}/.tmux.conf;

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
