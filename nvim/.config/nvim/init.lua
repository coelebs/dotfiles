require "user.options"
require "user.keymaps"
require "user.plugins"
require "user.cmp"
require "user.lsp"
require "user.git"
require "user.treesitter"
require "user.telescope"
require "user.nvimtree"
require "user.toggleterm"
require "user.autopairs"
require "user.fidget"

vim.cmd [[                           
let g:vimwiki_list = [{'path': '~/local/wiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]
]]

vim.cmd [[autocmd FileType go lua require('user.ft.go')]]
vim.cmd [[autocmd FileType typescript lua require('user.ft.typescript')]]
vim.cmd [[autocmd FileType markdown lua require('user.ft.markdown')]]
