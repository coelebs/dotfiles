"""""""""""""
" Variables "
"""""""""""""
syntax on
set number
set background=dark
set history=1000
set hidden                           " Enable hiding unsaved buffers
set autoread
colorscheme herald
set nocompatible                     " Don't be compatible with vi
set ruler                            " Tell me where I am in the statusbar
set hlsearch                         " Highlight if I find something
set incsearch                        " Start searching while I type filetype on                          " Enable filetype
filetype plugin on
filetype indent on
set omnifunc=syntaxcomplete#Complete
set wildmenu                         " Show list instead of just completing
set ignorecase                       " Make searches case sensitive only if the capital letter is in the search expression.
set smartcase
set foldmethod=syntax
set scrolloff=10                     " Start scrolling three lines from the edge
set backupdir=~/.vim/tmp             " Backup all .swp en backup files in .vim/tmp and not everywhere
set directory=~/.vim/tmp
set shortmess=atI
set tabstop=4                        " Tab settings
set shiftwidth=4
set softtabstop=4
set smarttab
set smartindent
set cpoptions+=$                     " Append dollar sign instead of removing the word, thanks Derek Wyatt
set mat=5                            " Show matching brackets for 0.9 seconds
"set virtualedit=all                 " Just go everywhere!!
set visualbell t_vb=".
set novisualbell
set completeopt=menu,longest,preview
set tags=./tags
set listchars=tab:▸\ 

command Makeprg :echo "No makefile found and no makeprg set" 
command Runprg :echo "No makefile found and no runprg set"

highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match ErrorMsg /\%81v.\+/

""""""""""""
" Mappings "
""""""""""""
"nmap ; :

map <F2> :NERDTreeToggle<CR>
map <F4> :set list!<CR>
map <F5> :set hls!<CR>
map <F9> :w<CR>:!cat % \| wgetpaste<CR>
map <F11> :call Run()<CR>
map <F12> :wall<CR>:Make<CR>
map <ctrl-c> :wall<CR>:Make<Cr>

let mapleader = ","

map <Leader>t :NERDTreeToggle<CR>
map <Leader>m :wall<CR>:Make<CR>

"""""""""""""
" Functions "
"""""""""""""
command Make :call CustomMake()
function! CustomMake()
	if filereadable('Makefile')
		make
	else
		Makeprg
	endif
endfunction

function Run()
	if filereadable('Makefile')
		make test
	else
		Runprg
	endif
endfunction

"""""""""""""
" Filetypes "
"""""""""""""
if has("autocmd")
	autocmd filetype java command! Makeprg :!javac %
	autocmd filetype java set errorformat=%A%f:%l:\ %m,%-Z%p^,%-C%.%#
	autocmd filetype java set tags+=~/.vim/tags/javatags
	autocmd filetype java command! Runprg :!java %:r

	autocmd filetype c command! Makeprg :!gcc % -o %:r
	autocmd filetype c set tags+=~/.vim/tags/ctags
	autocmd filetype c map <F10> :!sdcc %<CR>
	autocmd filetype c command! Runprg :!./%:r <CR>

	autocmd filetype cpp set tags+=~/.vim/tags/cpptags
	autocmd filetype cpp set tags+=~/.vim/tags/cpp
	autocmd filetype cpp command! Makeprg :!g++ -g -Wall "%" -o "%:r"
	autocmd filetype cpp command! Runprg :!./%:r <CR>
	autocmd filetype cpp map <F10> :!ctags -R --c++-kinds=+pl --fields=+iaS --extra=+q .<CR>

	autocmd filetype tex set textwidth=80
	autocmd filetype tex command! Runprg :!epdfview %:r.pdf <CR>
	autocmd filetype tex command! Makeprg :!latex %; dvipdfm %:r
	autocmd BufNewFile *.tex 0r ~/.vim/templates/tex

	autocmd BufNewFile *.txt set filetype=text
	autocmd filetype text set textwidth=80

	autocmd BufNewFile PKGBUILD 0r /usr/share/pacman/PKGBUILD.proto

	"autocmd filetype php set omnifunc=phpcomplete#CompletePHP
	autocmd filetype php let php_sql_query=1
	autocmd filetype php let php_htmlInStrings=1
	
	autocmd filetype perl command! Makeprg :!perl %
	autocmd filetype perl command! Runprg :!perl %
	autocmd BufNewFile *.pl 0r ~/.vim/templates/perl

	autocmd filetype python set shiftwidth=4
	autocmd filetype python set expandtab
	autocmd filetype python command! Makeprg :!python %
	autocmd filetype python command! Runprg :!python %
	autocmd filetype python set tags=~/.vim/tags/pythontags
	autocmd filetype python map <F10> :!python manage.py runserver<CR>

	autocmd filetype haskell command! Makeprg :!ghc --make %
	autocmd filetype haskell command! Runprg :!./%:r<CR>

	autocmd BufNewFile *.class.php 0r ~/.vim/templates/class.php
	autocmd filetype php iab $. $this->
endif

"""""""""""
" Plugins "
"""""""""""

" Timestamp options
let timestamp_regexp = '\v\C%(<Last %([cC]hanged?|[Mm]odified):\s+)@<=.*$' 
let timestamp_regexp = '\v\C%(<Last %([cC]hanged?|[Mm]odified):\s+)@<=.*$' 


let OmniCpp_NamespaceSearch = 1
let OmniCpp_GlobalScopeSearch = 1
let OmniCpp_ShowAccess = 1
let OmniCpp_MayCompleteDot = 1      " autocomplete with .
let OmniCpp_MayCompleteArrow = 1    " autocomplete with ->
let OmniCpp_MayCompleteScope = 1    " autocomplete with ::
let OmniCpp_SelectFirstItem = 2     " select first item (but don't insert)
let OmniCpp_NamespaceSearch = 2     " search namespaces in this and included files
let OmniCpp_ShowPrototypeInAbbr = 1 " show function prototype (i.e. parameters) in popup window

let g:SuperTabDefaultCompletionType = "<c-x><c-o>"

let g:snips_author = "Vincent Kriek"

let protodefprotogetter = "~/.vim/pullproto.pl"

let g:clj_highlight_builtins=1      " Highlight Clojure's builtins
let g:clj_paren_rainbow=1           " Rainbow parentheses'!k
