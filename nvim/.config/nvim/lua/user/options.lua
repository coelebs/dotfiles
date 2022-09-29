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

vim.opt.cpoptions:append("$")  -- Append dollar sign instead of removing the word, thanks Derek Wyatt
vim.opt.undofile = true
vim.opt.clipboard = "unnamedplus"

vim.g.catppuccin_flavour = "mocha" -- latte, frappe, macchiato, mocha

require("catppuccin").setup(
{
  integrations = {
    fidget = true,
    native_lsp = {
      enabled = true,
      virtual_text = {
        errors = { "italic" },
        hints = { "italic" },
        warnings = { "italic" },
        information = { "italic" },
      },
      underlines = {
        errors = { "underline" },
        hints = { "underline" },
        warnings = { "underline" },
        information = { "underline" },
      },
    },
  }
}
)

vim.cmd [[colorscheme gruvbox]]
