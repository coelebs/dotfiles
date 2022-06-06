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
vim.opt.tabstop        = 4
vim.opt.shiftwidth     = 4
vim.opt.softtabstop    = 4
vim.opt.expandtab      = true
vim.opt.completeopt    = {"menu", "menuone", "noselect"}
vim.opt.numberwidth    = 5
vim.opt.relativenumber = true


vim.opt.cpoptions:append("$")  -- Append dollar sign instead of removing the word, thanks Derek Wyatt

vim.cmd [[ colorscheme dracula ]]
