local fn = vim.fn
local install_path = fn.stdpath("data").."/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path})
end

local packer_config = {
}

local plugins = function(use)
      -- Packer can manage itself
      use("wbthomason/packer.nvim")

      -- completion
      use("hrsh7th/nvim-cmp") -- The completion plugin
      use("hrsh7th/cmp-buffer") -- buffer completions
      use("hrsh7th/cmp-path") -- path completions
      use("hrsh7th/cmp-cmdline") -- cmdline completions
      use("hrsh7th/cmp-nvim-lsp")
      use("hrsh7th/cmp-nvim-lua")
      use("saadparwaiz1/cmp_luasnip") -- snippet completions
      use("github/copilot.vim")

      -- snippets
      use("L3MON4D3/LuaSnip") --snippet engine
      use("rafamadriz/friendly-snippets") -- a bunch of snippets to use

      -- LSP
      use("neovim/nvim-lspconfig")
      use("williamboman/nvim-lsp-installer") -- simple to use language server installer

      -- Git
      use({ "TimUntersberger/neogit", requires = "nvim-lua/plenary.nvim" })
      use({ "sindrets/diffview.nvim", requires = "nvim-lua/plenary.nvim" })
      use({ "lewis6991/gitsigns.nvim", requires = "nvim-lua/plenary.nvim" })

      -- Supercool neovim
      use("nvim-telescope/telescope.nvim")
      use("nvim-telescope/telescope-fzy-native.nvim")
      use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate", })
      use("nvim-treesitter/nvim-treesitter-context")
      use("akinsho/toggleterm.nvim")
      use("lukas-reineke/indent-blankline.nvim")
      use("folke/trouble.nvim")

      -- Colorschemes
      use("dracula/vim")

      -- Unsure if i"ll keep it
      use("windwp/nvim-autopairs")
      use("j-hui/fidget.nvim")

      -- Markdown
      use({
          "iamcco/markdown-preview.nvim",
          run = function() vim.fn["mkdp#util#install"]() end,
          ft = {"markdown"}
      })
      -- Need to figure out how to update keybindings
      -- use({"dhruvasagar/vim-table-mode"})

      use("vimwiki/vimwiki")
  end


return require("packer").startup({plugins, config = packer_config})
