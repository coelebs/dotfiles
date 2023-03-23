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

      -- LSP
      use("neovim/nvim-lspconfig")
      use("j-hui/fidget.nvim")

      -- Git
      use({ "lewis6991/gitsigns.nvim", requires = "nvim-lua/plenary.nvim" })
      use("tpope/vim-fugitive")

      -- Telescope
      use("nvim-telescope/telescope.nvim")
      use("nvim-telescope/telescope-fzy-native.nvim")

      -- Treesitter
      use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate", })
      use("nvim-treesitter/nvim-treesitter-context")

      use("akinsho/toggleterm.nvim")
      use("lukas-reineke/indent-blankline.nvim")
      use("folke/trouble.nvim")

      -- Colorschemes
      use("dracula/vim")
      use({ "catppuccin/nvim", as = "catppuccin" })
      use("morhetz/gruvbox")

      -- Markdown
      use({
          "iamcco/markdown-preview.nvim",
          run = function() vim.fn["mkdp#util#install"]() end,
          ft = {"markdown"}
      })
      -- Need to figure out how to update keybindings
      -- use({"dhruvasagar/vim-table-mode"})

      use("vimwiki/vimwiki")

      use("ThePrimeagen/harpoon")

      --debugger
      use("mfussenegger/nvim-dap")
      use("theHamsta/nvim-dap-virtual-text")
      use("rcarriga/nvim-dap-ui")

      use("mbbill/undotree")

      use("jose-elias-alvarez/null-ls.nvim")
      use({
          "ThePrimeagen/refactoring.nvim",
          requires = {
            {"nvim-lua/plenary.nvim"},
            {"nvim-treesitter/nvim-treesitter"}
          }
      })



      use({
        'pwntester/octo.nvim',
        requires = {
          'nvim-lua/plenary.nvim',
          'nvim-telescope/telescope.nvim',
          'kyazdani42/nvim-web-devicons',
        },
        config = function ()
          require"octo".setup()
        end
      })

      use("github/copilot.vim")

      --temporary
      use("takac/vim-hardtime")
  end


return require("packer").startup({plugins, config = packer_config})
