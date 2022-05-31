local opts = { noremap = true, silent = true }
local keymap = vim.api.nvim_set_keymap

keymap("", " ", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.mapleader = " "

keymap("n", "<leader>g", ":Neogit<cr>", opts)
keymap("n", "<leader>gd", ":Gitsigns preview_hunk<cr>", opts)
keymap("n", "<leader>gs", ":Gitsigns stage_hunk<cr>", opts)

keymap("n", "<leader>f", ":Telescope live_grep<cr>", opts)
keymap("n", "<leader>b", ":lua require'telescope.builtin'.buffers{}<cr>", opts)
keymap("n", "<leader>r", ":lua require'telescope.builtin'.lsp_references{}<cr>", opts)
keymap("n", "<leader>t", ":TroubleToggle<cr>", opts)

keymap("n", "<leader>qc", ":cclose<cr>", opts)

keymap("n", "<F2>", ":NvimTreeToggle<cr>", opts)
keymap("n", "<F4>", ":set list!<cr>", opts)

keymap("n", "<F5>", ":set hls!<cr>", opts)

keymap("n", "<F7>", ":cprev<cr>", opts)
keymap("n", "<F8>", ":cnext<cr>", opts)

keymap("n", "<c-f>", ":Telescope find_files<cr>", opts)

keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

keymap("n", "<C-n>", ":e ~/Documents/notes.md<CR>Go", opts)
