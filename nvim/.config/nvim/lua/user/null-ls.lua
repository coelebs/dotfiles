local ok, null_ls = pcall(require, "null-ls")
if not ok then
    vim.notify("nvim-autopairs not installed")
    return
end

null_ls.setup({
    sources = {
        null_ls.builtins.formatting.clang_format,
        null_ls.builtins.formatting.gofmt,
    },
})
