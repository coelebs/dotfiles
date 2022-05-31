vim.opt.tabstop     = 4
vim.opt.shiftwidth  = 4
vim.opt.softtabstop = 4
vim.opt.expandtab   = false

local opts = { noremap = true, silent = true }

vim.api.nvim_set_keymap("n", "<leader>rt", ":AsyncRun go test ./pkg/...<cr>:copen<cr>", opts)
