return {
    "nvim-telescope/telescope.nvim",
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = "Telescope",
    keys = {
	     {"<leader>ff", ":Telescope find_files<cr>"},
	     {"<leader>fg", ":Telescope git_files<cr>"},
	     {"<leader>rg", ":Telescope live_grep<cr>"},
	     {"<leader>r*", function() require("telescope.builtin").grep_string() end},
	     {"<leader>fb", function() require("telescope.builtin").buffers() end},
	     {"<leader>fh", function() require("telescope.builtin").help_tags() end},
	     {"<leader>fs", function() require("telescope.builtin").git_status() end},
         {"<leader>fr", function() require("telescope.builtin").resume() end},
    },
    config = function()
      require("telescope").setup{
        defaults = {
          mappings = {
            i = {
              ["<C-h>"] = "which_key"
            }
          },
          layout_strategy = "vertical"
        },
      }
    end
}
