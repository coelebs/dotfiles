local M = {}

function M.setup()
  local lint = require('lint')
  lint.linters_by_ft = { sh = { 'shellcheck' }, bash = { 'shellcheck' } }
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
    group = vim.api.nvim_create_augroup('user-shellcheck', { clear = true }),
    callback = function()
      if vim.bo.filetype == 'sh' or vim.bo.filetype == 'bash' then
        lint.try_lint()
      end
    end,
  })
end

return M
