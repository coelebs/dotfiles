local ok, configs = pcall(require, "nvim-treesitter.configs")
if not ok then
    vim.notify("Treesitter not installed")
    return
end

configs.setup{}
