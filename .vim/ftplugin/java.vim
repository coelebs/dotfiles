set shiftwidth=4
set tabstop=4

set makeprg=javac\ %
"set errorformat=%A%f:%l:\ %m,%-Z%p^,%-C%.%#
set efm=%A%f:%l:\ %m,%+Z%p^,%+C%.%#,%-G%.%#
map n :cn<CR>
map <F11> :!/usr/bin/java %:r <CR>
map <F12> :w<CR>:make<CR>

set makeprg=javac\ %
set errorformat=%A%f:%l:\ %m,%-Z%p^,%-C%.%#

set foldmethod=syntax
set foldenable

set tags=~/.vim/tags/javatags

syn region foldJavadoc start=,/\*\*, end=,\*/, transparent fold keepend
set foldlevel=0

iab pr private
iab pe protected
iab pu public

iab ex extends

iab bo boolean
iab St String

iab ab abstract
iab cl class
iab st static
iab fi final
iab ir import
iab pkg package
iab sou System.out.println(
iab re return
iab sw switch
iab psvm public static void main(String[] args) {
