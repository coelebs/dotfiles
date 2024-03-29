return {
  {
  "neovim/nvim-lspconfig",
  dependencies = {"williamboman/mason-lspconfig.nvim", "williamboman/mason.nvim"},
  build = ":MasonUpdate", -- :MasonUpdate updates registry contents
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup()
    local function on_attach(client, bufnr)
      local opts = { noremap = true, silent = true }
      vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "gh", "<cmd>:ClangdSwitchSourceHeader<CR>", opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
      vim.api.nvim_buf_set_keymap(bufnr, "i", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ee", "<cmd>lua require('telescope.builtin').diagnostics()<CR>", opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ef", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ej", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ek", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>fws", "<cmd>lua require('telescope.builtin').lsp_dynamic_workspace_symbols()<CR>", opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>fds", "<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>", opts)
      vim.api.nvim_buf_set_keymap(
      bufnr,
      "n",
      "gl",
      '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics({ border = "rounded" })<CR>',
      opts
      )
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
      vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
    end

    require("mason-lspconfig").setup_handlers({
      function(server_name)
        require('lspconfig')[server_name].setup{
          on_attach = on_attach,
          flags = lsp_flags,
        }
      end,
    })
  end
  },
}
