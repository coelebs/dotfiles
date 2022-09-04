require("user.options")
require("user.keymaps")
require("user.plugins")
require("user.cmp")
require("user.lsp")
require("user.git")
require("user.treesitter")
require("user.telescope")
require("user.nvimtree")
require("user.toggleterm")
require("user.fidget")
require("user.functions")
require("user.debuggers")

vim.cmd [[
let g:vimwiki_list = [{'path': '~/projects/wiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]
]]

local coelebsgroup = vim.api.nvim_create_augroup('coelebsgroup',  {})

vim.api.nvim_create_autocmd({"BufWritePre"}, {
    group = coelebsgroup,
    pattern = "*",
    command = "%s/\\s\\+$//e",
})
require("indent_blankline").setup {}
