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

vim.opt.cpoptions:append("$")  -- Append dollar sign instead of removing the word, thanks Derek Wyatt
vim.opt.undofile = true
vim.opt.clipboard = "unnamedplus"

vim.cmd [[colorscheme gruvbox]]

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}
