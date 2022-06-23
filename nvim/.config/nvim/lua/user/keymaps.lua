local function nnoremap(lhs, rhs)
    vim.keymap.set("n", lhs, rhs, { noremap = true })
end

vim.g.mapleader = " "

nnoremap("<leader>gg", ":Neogit<cr>")
nnoremap("<leader>gd", ":Gitsigns preview_hunk<cr>")
nnoremap("<leader>gs", ":Gitsigns stage_hunk<cr>")

nnoremap("<c-f>", ":Telescope find_files<cr>")
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


nnoremap("<C-h>", "<C-w>h")
nnoremap("<C-j>", "<C-w>j")
nnoremap("<C-k>", "<C-w>k")
nnoremap("<C-l>", "<C-w>l")
