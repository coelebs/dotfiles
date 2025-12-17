return {
  {
    "lewis6991/gitsigns.nvim",
    keys = {
      {"<leader>gd", ":Gitsigns preview_hunk<cr>"},
      {"<leader>gs", ":Gitsigns stage_hunk<cr>"},
      {"<leader>gS", ":Gitsigns stage_buffer<cr>"},
      {"<leader>gr", ":Gitsigns reset_hunk<cr>"},
      {"<leader>gR", ":Gitsigns reset_buffer<cr>"},
      {"<leader>gn", ":Gitsigns next_hunk<cr>"},
      {"<leader>gp", ":Gitsigns prev_hunk<cr>"},
      {"<leader>gb", ":Gitsigns blame_line<cr>"},
    },
    event = "BufReadPre",
    config = function()
      require("gitsigns").setup { }
    end
  },
  {
    "tpope/vim-fugitive",
    keys = {
      {"<leader>gg", ":Git<cr>"},
    },
    cmd = {"Gedit", "Git"},
  }
}
