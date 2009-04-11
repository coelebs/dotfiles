if filereadable("/etc/vim/vimrc.local")
	    source /etc/vim/vimrc.local
endif

let timestamp_regexp = '\v\C%(<Last %([cC]hanged?|[Mm]odified):\s+)@<=.*$' 
let timestamp_regexp = '\v\C%(<Last %([cC]hanged?|[Mm]odified):\s+)@<=.*$' 
set number
set background=dark
set history=1000
set wildmenu
filetype plugin on

"Make searches case sensitive only if the capital letter is in the search
"expression.
set ignorecase
set smartcase

set scrolloff=3

"Backup all .swp en backup files in .vim/tmp and not everywhere
set backupdir=~/.vim/tmp
set directory=~/.vim/tmp

set shortmess=atI

"Tab settings
set ts=2
set shiftwidth=2
set smarttab

"Visual bells off
set vb t_vb=".

map <F12> :make<CR>
