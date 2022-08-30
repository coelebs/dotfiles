local ok, null_ls = pcall(require, "null-ls")
if not ok then
    vim.notify("nvim-autopairs not installed")
    return
end

null_ls.setup({
    sources = {
    },
})

local formatgrp = vim.api.nvim_create_augroup("Formatting", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = vim.lsp.buf.formatting_sync,
  pattern = "*.go,*.c,*.h,*.cpp",
  group = formatgrp,
})
