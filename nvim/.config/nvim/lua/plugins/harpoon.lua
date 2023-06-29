return {
  "theprimeagen/harpoon",
  keys = {
    {"<leader>a", function() require("harpoon.mark").add_file() end},
    {"<C-e>", function() require("harpoon.ui").toggle_quick_menu() end},
    {"'a", function() require("harpoon.ui").nav_file(1) end},
    {"'s", function() require("harpoon.ui").nav_file(2) end},
    {"'d", function() require("harpoon.ui").nav_file(3) end},
    {"'f", function() require("harpoon.ui").nav_file(4) end},
  },
  config = function()
    require("harpoon").setup()
  end,
}
