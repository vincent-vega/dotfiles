set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc
let g:python3_host_prog=expand("~/.vim/nvim/nvim-venv/bin/python")
