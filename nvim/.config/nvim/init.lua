vim.cmd [[
let g:vimwiki_list = [{'path': '~/projects/wiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]
set makeprg=build.sh
]]

local coelebsgroup = vim.api.nvim_create_augroup('coelebsgroup',  {})
vim.api.nvim_create_autocmd({"BufWritePre"}, {
    group = coelebsgroup,
    pattern = "*",
    command = "%s/\\s\\+$//e",
})

vim.opt.number         = true
vim.opt.background     = "dark"
vim.opt.history        = 1000
vim.opt.hidden         = true
vim.opt.ignorecase     = true
vim.opt.smartcase      = true
vim.opt.foldmethod     = "syntax"
vim.opt.foldlevelstart = 20
vim.opt.scrolloff      = 10
vim.opt.matchtime      = 5
vim.opt.mouse          = "a"
vim.opt.tabstop        = 2
vim.opt.shiftwidth     = 2
vim.opt.softtabstop    = 2
vim.opt.expandtab      = true
vim.opt.completeopt    = {"menu", "menuone", "noselect"}
vim.opt.numberwidth    = 5
vim.opt.relativenumber = true
vim.opt.guicursor = ""
vim.opt.termguicolors = true

vim.opt.cpoptions:append("$")  -- Append dollar sign instead of removing the word, thanks Derek Wyatt
vim.opt.undofile = true
vim.opt.clipboard = "unnamedplus"

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>ex", ":Ex<cr>")
vim.keymap.set("n", "<leader>qc", ":cclose<cr>")
vim.keymap.set("n", "<F4>", ":set list!<cr>")
vim.keymap.set("n", "<F5>", ":set hls!<cr>")
vim.keymap.set("n", "<C-k>", ":cprev<cr>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-j>", ":cnext<cr>zz")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

function build(run)
  require("notify")("Building...", "info", {title = "Build"})
  vim.fn.jobstart({"build.sh"}, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      vim.fn.setqflist(data, "r")
    end,
    on_exit = function(_, code)
      if code ~= 0 then
        require("notify")("Build failed", "error", {title = "Build"})
      elseif run then
        require("notify")("Starting debugger after build", "info", {title = "Build"})
        require("dap").terminate()
        require("dap").continue()
      else
        require("notify")("Build succeeded", "info", {title = "Build"})
      end
    end
  })
end

vim.keymap.set("n", "<leader>bb", function() build(false) end)
vim.keymap.set("n", "<leader>bs", function() build(true) end)

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup("plugins", opts)
