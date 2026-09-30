vim.g.mapleader = ' '
vim.g.copilot_enterprise_uri = 'https://alfen.ghe.com'
vim.g.copilot_enterprise_url = 'https://alfen.ghe.com'
vim.g.markdown_folding = 1

vim.opt.makeprg = 'build.sh'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 5
vim.opt.signcolumn = 'auto:1-2'
vim.opt.history = 1000
vim.opt.hidden = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.foldmethod = 'syntax'
vim.opt.foldlevelstart = 20
vim.opt.scrolloff = 10
vim.opt.matchtime = 5
vim.opt.mouse = 'a'
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.opt.guicursor = ''
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.cpoptions:append('$')

vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup('user-trim-whitespace', { clear = true }),
  callback = function()
    local view = vim.fn.winsaveview()
    vim.cmd([[silent! keepjumps %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('user-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.filetype.add({ pattern = { ['jenkinsfile.*'] = 'groovy' } })

local map = vim.keymap.set
map('n', '<leader>ex', '<cmd>Oil<cr>')
map('n', '<leader>qc', '<cmd>cclose<cr>')
map('n', '<F4>', '<cmd>set list!<cr>')
map('n', '<F5>', '<cmd>set hls!<cr>')
map('n', '<C-k>', '<cmd>cprev<cr>zz')
map('n', '<C-j>', '<cmd>cnext<cr>zz')
map('n', '<C-u>', '<C-u>zz')
map('n', '<C-d>', '<C-d>zz')
map('v', 'J', ":m '>+1<cr>gv=gv")
map('v', 'K', ":m '<-2<cr>gv=gv")
map('n', '<C-f>', '<cmd>silent !tmux neww workdeck<cr>')
map('n', '<leader>dd', ':r!date<cr>')

require('user.theme').setup()
require('user.plugins').setup()
require('user.lsp').setup()
require('user.lint').setup()
