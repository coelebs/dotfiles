local nnoremap = require("user.keymaps").nnoremap

vim.g.mapleader = " "

nnoremap("<leader>gg", ":Neogit<cr>")
nnoremap("<leader>gd", ":Gitsigns preview_hunk<cr>")
nnoremap("<leader>gs", ":Gitsigns stage_hunk<cr>")
nnoremap("<leader>gS", ":Gitsigns stage_buffer<cr>")
nnoremap("<leader>gr", ":Gitsigns reset_hunk<cr>")
nnoremap("<leader>gR", ":Gitsigns reset_buffer<cr>")

nnoremap("<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
nnoremap("<leader>ff", ":Telescope find_files<cr>")
nnoremap("<leader>fg", ":Telescope live_grep<cr>")
nnoremap("<leader>fb", require("telescope.builtin").buffers)
nnoremap("<leader>fh", require("telescope.builtin").help_tags)
nnoremap("<leader>fr", require("telescope.builtin").lsp_references)
nnoremap("<leader>tt", "<cmd>TroubleToggle<cr>")
nnoremap("<leader>td", "<cmd>TroubleToggle document_diagnostics<cr>")

nnoremap("<leader>qc", ":cclose<cr>")

nnoremap("<F4>", ":set list!<cr>")

nnoremap("<F5>", ":set hls!<cr>")

nnoremap("<F7>", ":cprev<cr>")
nnoremap("<F8>", ":cnext<cr>")

nnoremap("<C-p>", ":cprev<cr>zz")
nnoremap("<C-n>", ":cnext<cr>zz")

nnoremap("<leader>a", function() require("harpoon.mark").add_file() end)
nnoremap("<C-e>", function() require("harpoon.ui").toggle_quick_menu() end)

nnoremap("'a", function() require("harpoon.ui").nav_file(1) end)
nnoremap("'s", function() require("harpoon.ui").nav_file(2) end)
nnoremap("'d", function() require("harpoon.ui").nav_file(3) end)
nnoremap("'f", function() require("harpoon.ui").nav_file(4) end)

nnoremap("<C-u>", "<C-u>zz")
nnoremap("<C-d>", "<C-d>zz")
