local M = {}

function M.setup()
  require('oil').setup()
  require('gitsigns').setup({ attach_to_untracked = true })
  require('lualine').setup()
  require('harpoon').setup()
  require('todo-comments').setup()
  require('trouble').setup()

  local cmp = require('cmp')
  cmp.setup({
    mapping = cmp.mapping.preset.insert({
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-b>'] = cmp.mapping.scroll_docs(-1),
      ['<C-f>'] = cmp.mapping.scroll_docs(1),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'path' },
      { name = 'buffer' },
    }),
  })
  cmp.setup.cmdline('/', { sources = { { name = 'buffer' } } })

  require('telescope').setup({
    defaults = {
      layout_strategy = 'vertical',
      layout_config = { vertical = { preview_cutoff = 10 } },
      mappings = { i = { ['<C-h>'] = 'which_key' } },
    },
  })

  local map = vim.keymap.set
  map('n', '<leader>gg', '<cmd>Git<cr>')
  for key, command in pairs({
    gd = 'preview_hunk',
    gs = 'stage_hunk',
    gS = 'stage_buffer',
    gr = 'reset_hunk',
    gR = 'reset_buffer',
    gn = 'next_hunk',
    gp = 'prev_hunk',
    gb = 'blame_line',
  }) do
    map('n', '<leader>' .. key, '<cmd>Gitsigns ' .. command .. '<cr>')
  end

  map('n', '<leader>a', function()
    require('harpoon.mark').add_file()
  end)
  map('n', '<C-e>', function()
    require('harpoon.ui').toggle_quick_menu()
  end)
  for index, key in ipairs({ 'a', 's', 'd', 'f' }) do
    map('n', "'" .. key, function()
      require('harpoon.ui').nav_file(index)
    end)
  end

  local telescope = require('telescope.builtin')
  for key, picker in pairs({
    ff = 'find_files',
    fg = 'git_files',
    rg = 'live_grep',
    ['r*'] = 'grep_string',
    fb = 'buffers',
    fh = 'help_tags',
    fs = 'git_status',
    fr = 'resume',
  }) do
    map('n', '<leader>' .. key, telescope[picker])
  end
  map('n', '<leader>ud', '<cmd>UndotreeToggle<cr>')

  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('user-treesitter', { clear = true }),
    pattern = {
      'sh',
      'c',
      'cpp',
      'go',
      'json',
      'lua',
      'markdown',
      'nix',
      'python',
      'rust',
      'toml',
      'vim',
      'yaml',
      'zsh',
    },
    callback = function(event)
      pcall(vim.treesitter.start, event.buf)
    end,
  })
end

return M
