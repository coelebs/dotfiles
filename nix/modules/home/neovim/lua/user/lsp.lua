local M = {}

function M.setup()
  vim.diagnostic.config({
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    virtual_text = { source = 'if_many', spacing = 2 },
  })

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('user-lsp', { clear = true }),
    callback = function(event)
      local function map(keys, action, description, mode)
        vim.keymap.set(
          mode or 'n',
          keys,
          action,
          { buffer = event.buf, desc = 'LSP: ' .. description }
        )
      end

      local telescope = require('telescope.builtin')
      map('<leader>rn', vim.lsp.buf.rename, 'Rename')
      map('<leader>ca', vim.lsp.buf.code_action, 'Code action', { 'n', 'x' })
      map('gr', vim.lsp.buf.references, 'References')
      map('gi', telescope.lsp_implementations, 'Implementation')
      map('gd', telescope.lsp_definitions, 'Definition')
      map('gD', vim.lsp.buf.declaration, 'Declaration')
      map('gO', telescope.lsp_document_symbols, 'Document symbols')
      map('gW', telescope.lsp_dynamic_workspace_symbols, 'Workspace symbols')
      map('grt', telescope.lsp_type_definitions, 'Type definition')
      map('gh', '<cmd>find %:t:r.*<cr>', 'Header')
      map('K', vim.lsp.buf.hover, 'Hover')
      map('<C-k>', vim.lsp.buf.signature_help, 'Signature help', 'i')

      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client:supports_method('textDocument/inlayHint', event.buf) then
        map('<leader>th', function()
          vim.lsp.inlay_hint.enable(
            not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }),
            { bufnr = event.buf }
          )
        end, 'Toggle inlay hints')
      end
    end,
  })

  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  local clangd_cmd = { 'clangd' }
  local query_driver = vim.env.CLANGD_QUERY_DRIVER
    or '/opt/gcc-arm-none-eabi-9-2020-q2-update/bin/arm-none-eabi-g++'
  if vim.fn.executable(query_driver) == 1 then
    table.insert(clangd_cmd, '--query-driver=' .. query_driver)
  end
  vim.lsp.config('clangd', { cmd = clangd_cmd, capabilities = capabilities })
  vim.lsp.config('gopls', { capabilities = capabilities })
  vim.lsp.config('lua_ls', {
    capabilities = capabilities,
    settings = { Lua = { completion = { callSnippet = 'Replace' } } },
  })
  vim.lsp.config('nixd', { capabilities = capabilities })
  vim.lsp.config('pyright', { capabilities = capabilities })
  vim.lsp.enable({ 'clangd', 'gopls', 'lua_ls', 'nixd', 'pyright' })
end

return M
