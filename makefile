bash_dir=${HOME}/dotfiles/bash
dotfiles_dir=${HOME}/dotfiles/bash
vim_dir=${HOME}/dotfiles/vim

.PHONY: link

link: bash vim
	@echo "Link target complete!"

bash: ${bash_dir} ${bash_dir}/bashrc ${bash_dir}/bash_profile ${bash_dir}/inputrc
	ln -s ${bash_dir}/bashrc ${HOME}/.bashrc;
	ln -s ${bash_dir}/bash_profile ${HOME}/.bash_profile;
	ln -s ${bash_dir}/inputrc ${HOME}/.inputrc;

vim: ${vim_dir} ${vim_dir}/vimrc ${vim_dir}/gvimrc
	ln -s ${vim_dir} ${HOME}/.vim;
	ln -s ${vim_dir}/vimrc ${HOME}/.vimrc;
	ln -s ${vim_dir}/gvimrc ${HOME}/.gvimrc;

others: ${dotfiles_dir}
	ln -s ${dotfiles_dir}/tmux.conf ${HOME}/.tmux.conf;

clean: ${HOME}/.tmux.conf ${HOME}/.bashrc ${HOME}/.bash_profile ${HOME}/.inputrc ${HOME}/.vim ${HOME}/.vimrc ${HOME}/.gvimrc
	@rm -f $^

forceclean:
	@rm -f ${HOME}/.bash_profile;
	@rm -f ${HOME}/.bashrc;
	@rm -f ${HOME}/.gvimrc;
	@rm -f ${HOME}/.inputrc;
	@rm -f ${HOME}/.tmux.conf;
	@rm -f ${HOME}/.vim;
	@rm -f ${HOME}/.vimrc;

