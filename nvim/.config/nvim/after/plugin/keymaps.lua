local nnoremap = require("user.keymaps").nnoremap
local vnoremap = require("user.keymaps").vnoremap

vim.g.mapleader = " "

nnoremap("<leader>ex", ":Ex<cr>")

nnoremap("<leader>gg", ":Git<cr>")
nnoremap("<leader>gd", ":Gitsigns preview_hunk<cr>")
nnoremap("<leader>gs", ":Gitsigns stage_hunk<cr>")
nnoremap("<leader>gS", ":Gitsigns stage_buffer<cr>")
nnoremap("<leader>gr", ":Gitsigns reset_hunk<cr>")
nnoremap("<leader>gR", ":Gitsigns reset_buffer<cr>")
nnoremap("<leader>gn", ":Gitsigns next_hunk<cr>")
nnoremap("<leader>gp", ":Gitsigns prev_hunk<cr>")

nnoremap("<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
nnoremap("<leader>ff", ":Telescope git_files<cr>")
nnoremap("<leader>fg", ":Telescope live_grep<cr>")
nnoremap("<leader>fb", require("telescope.builtin").buffers)
nnoremap("<leader>fh", require("telescope.builtin").help_tags)
nnoremap("<leader>fr", require("telescope.builtin").lsp_references)

nnoremap("<leader>ud", ":UndotreeToggle<cr>")

nnoremap("<leader>qc", ":cclose<cr>")

nnoremap("<F4>", ":set list!<cr>")
nnoremap("<F5>", ":set hls!<cr>")

nnoremap("<C-j>", ":cnext<cr>zz")
nnoremap("<C-k>", ":cprev<cr>zz")

nnoremap("<leader>a", function() require("harpoon.mark").add_file() end)
nnoremap("<C-e>", function() require("harpoon.ui").toggle_quick_menu() end)

nnoremap("'a", function() require("harpoon.ui").nav_file(1) end)
nnoremap("'s", function() require("harpoon.ui").nav_file(2) end)
nnoremap("'d", function() require("harpoon.ui").nav_file(3) end)
nnoremap("'f", function() require("harpoon.ui").nav_file(4) end)

nnoremap("<C-u>", "<C-u>zz")
nnoremap("<C-d>", "<C-d>zz")

vnoremap("J", ":m '>+1<CR>gv=gv")
vnoremap("K", ":m '<-2<CR>gv=gv")

-- Remaps for the refactoring operations currently offered by the plugin
vim.api.nvim_set_keymap("v", "<leader>re", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>]], {noremap = true, silent = true, expr = false})
vim.api.nvim_set_keymap("v", "<leader>rf", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR>]], {noremap = true, silent = true, expr = false})
vim.api.nvim_set_keymap("v", "<leader>rv", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR>]], {noremap = true, silent = true, expr = false})
vim.api.nvim_set_keymap("v", "<leader>ri", [[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]], {noremap = true, silent = true, expr = false})

-- Extract block doesn't need visual mode
vim.api.nvim_set_keymap("n", "<leader>rb", [[ <Cmd>lua require('refactoring').refactor('Extract Block')<CR>]], {noremap = true, silent = true, expr = false})
vim.api.nvim_set_keymap("n", "<leader>rbf", [[ <Cmd>lua require('refactoring').refactor('Extract Block To File')<CR>]], {noremap = true, silent = true, expr = false})

-- Inline variable can also pick up the identifier currently under the cursor without visual mode
vim.api.nvim_set_keymap("n", "<leader>ri", [[ <Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]], {noremap = true, silent = true, expr = false})
