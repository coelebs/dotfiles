if filereadable("/etc/vim/vimrc.local")
	    source /etc/vim/vimrc.local
endif

syntax on
set number
set background=dark
set history=1000

colorscheme default

" Don't be compatible with vi
set nocompatible

" Tell me where I am in the statusbar
set ruler

" Highlight if I find something and start searching while I type
set hlsearch
set incsearch

" Enable FileType
filetype on
filetype plugin on
filetype indent on

" Make searches case sensitive only if the capital letter is in the search expression.
set ignorecase
set smartcase

" Folding
set foldmethod=syntax

" Start scrolling three lines from the edge
set scrolloff=3

" Backup all .swp en backup files in .vim/tmp and not everywhere
set backupdir=~/.vim/tmp
set directory=~/.vim/tmp
set shortmess=atI

" Tab settings
set tabstop=2
set shiftwidth=2
set smarttab
set smartindent

" Append dollar sign instead of removing the word, thanks Derek Wyatt
set cpoptions+=$

" Just go everywhere!!
set virtualedit=all

" Visual bells off
set vb t_vb=".

set runtimepath=~/.vim,/usr/share/vim,/usr/share/vim/vim72,/usr/share/vim/vimfiles/

map <F2> 	:NERDTree<CR>
map <F12> :w<CR>:make<CR>

" Filetypes
autocmd filetype java set makeprg=javac\ %
autocmd filetype java set errorformat=%A%f:%l:\ %m,%-Z%p^,%-C%.%#
autocmd filetype java set tags=~/.vim/tags/javatags
autocmd filetype java map <F11> :!/usr/bin/java %:r <CR>

autocmd filetype c set tags=~/.vim/tags/ctags
autocmd filetype c map <F10> :!sdcc %<CR>
autocmd filetype c map <F11> :!./%:r <CR>

autocmd filetype python set makeprg=python\ %
autocmd filetype python set tags=~/.vim/tags/pythontags

" Timestamp options
let timestamp_regexp = '\v\C%(<Last %([cC]hanged?|[Mm]odified):\s+)@<=.*$' 
let timestamp_regexp = '\v\C%(<Last %([cC]hanged?|[Mm]odified):\s+)@<=.*$' 

" OmniCompletionOptions
set completeopt=menu,menuone
let OmniCpp_NamespaceSearch=2
let OmniCpp_ShowPrototypeInAbbr=1
" let OmniCpp_MayCompleteScope=1
let g:SuperTabDefaultCompletionType = "<C-X><C-O>"
