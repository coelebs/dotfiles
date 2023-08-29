return {
    "nvim-treesitter/nvim-treesitter",
    config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = {"bash", "go", "python", "c", "cpp", "cmake", "dockerfile", "lua", "toml", "yaml", "devicetree", "git_rebase"},
          auto_install = true,
        })
      end,
    build = function()
        require("nvim-treesitter.install").update({ with_sync = true })
    end,
}
